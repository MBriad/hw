import { abilityDelegatorRegistry, Component, Driver, ON, Rect } from '@kit.TestKit';
import { describe, beforeAll, afterAll, it, expect } from '@ohos/hypium';
import { PreferencesCheckInRepo } from '../../../main/ets/adapters/PreferencesCheckInRepo';
import { SkinProviderImpl } from '../../../main/ets/adapters/SkinProviderImpl';
import { CheckIn } from '../../../main/ets/domain/CheckIn';
import { SkinTheme } from '../../../main/ets/domain/SkinTheme';

const FIXTURE_COUNT = 64;
const SAME_DATE = '2026-07-20';

async function component(driver: Driver, id: string): Promise<Component> {
  try {
    return await driver.waitForComponent(ON.id(id), 5000);
  } catch (error) {
    throw new Error(JSON.stringify(error));
  }
}

function sameBounds(left: Rect, right: Rect): boolean {
  return left.left === right.left && left.top === right.top &&
    left.right === right.right && left.bottom === right.bottom;
}

async function seed(repo: PreferencesCheckInRepo): Promise<void> {
  await repo.clear();
  for (let index = 0; index < FIXTURE_COUNT; index++) {
    let date = `2026-06-${String((index % 28) + 1).padStart(2, '0')}`;
    let content = `fixture commit ${index + 1}`;
    if (index === FIXTURE_COUNT - 2) {
      date = SAME_DATE;
      content = 'needle earlier same day';
    } else if (index === FIXTURE_COUNT - 1) {
      date = SAME_DATE;
      content = 'https://example.com/commit needle newest same day 中文';
    }
    await repo.save(new CheckIn(date, content, 100000 + index));
  }
}

async function openLogs(driver: Driver): Promise<void> {
  try {
    await (await component(driver, 'nav-logs')).click();
    await component(driver, 'logs-commit-index-rail');
  } catch (error) {
    throw new Error(JSON.stringify(error));
  }
}

async function search(driver: Driver, query: string): Promise<void> {
  try {
    const input = await component(driver, 'logs-search-input');
    await input.clearText();
    await input.inputText(query);
    await driver.delayMs(200);
    if (await input.getText() !== query) {
      await input.clearText();
      await input.inputText(query);
      await driver.delayMs(200);
    }
    expect(await input.getText()).assertEqual(query);
    await (await component(driver, 'logs-search-submit')).click();
    await driver.delayMs(200);
  } catch (error) {
    throw new Error(JSON.stringify(error));
  }
}

async function closeSearch(driver: Driver): Promise<void> {
  try {
    for (let attempt = 0; attempt < 2; attempt++) {
      const close = await driver.findComponent(ON.id('logs-search-close'));
      if (close === null) {
        return;
      }
      await close.click();
      await driver.delayMs(300);
    }
  } catch (error) {
    throw new Error(JSON.stringify(error));
  }
}

async function openSearch(driver: Driver): Promise<void> {
  try {
    const input = await driver.findComponent(ON.id('logs-search-input'));
    if (input !== null) {
      return;
    }
    await (await component(driver, 'logs-search-toggle')).click();
    await driver.delayMs(200);
    await component(driver, 'logs-search-input');
  } catch (error) {
    throw new Error(JSON.stringify(error));
  }
}

async function verifyTheme(driver: Driver, theme: SkinTheme): Promise<void> {
  try {
    await (await component(driver, 'nav-profile')).click();
    await (await component(driver, `theme-${theme}`)).click();
    await (await component(driver, 'nav-logs')).click();
    const rail = await component(driver, 'logs-commit-index-rail');
    const detail = await component(driver, 'logs-commit-detail');
    const toggle = await component(driver, 'logs-search-toggle');
    const railBounds = await rail.getBounds();
    const detailBounds = await detail.getBounds();
    expect(railBounds.right > railBounds.left).assertTrue();
    expect(detailBounds.right > railBounds.right).assertTrue();
    expect(await toggle.isEnabled()).assertTrue();
  } catch (error) {
    throw new Error(JSON.stringify(error));
  }
}

export default function abilityTest() {
  describe('LogsNavigationUi', () => {
    const delegator = abilityDelegatorRegistry.getAbilityDelegator();
    const driver = Driver.create();

    beforeAll(async (): Promise<void> => {
      await delegator.startAbility({
        bundleName: 'com.example.test',
        moduleName: 'entry',
        abilityName: 'EntryAbility',
      });
      await driver.delayMs(500);
      const mainAbility = await delegator.getCurrentTopAbility();
      const repo = new PreferencesCheckInRepo(mainAbility.context);
      const skinProvider = new SkinProviderImpl(mainAbility.context);
      await seed(repo);
      expect((await repo.loadAll()).length).assertEqual(FIXTURE_COUNT);
      await skinProvider.persist(SkinTheme.LIGHT);
      await skinProvider.persistLocale('zh');
      await mainAbility.context.terminateSelf();
      await driver.delayMs(300);
      await delegator.startAbility({
        bundleName: 'com.example.test',
        moduleName: 'entry',
        abilityName: 'EntryAbility',
      });
      await driver.delayMs(1000);
      await openLogs(driver);
    });

    afterAll(async (): Promise<void> => {
      const mainAbility = await delegator.getCurrentTopAbility();
      const repo = new PreferencesCheckInRepo(mainAbility.context);
      const skinProvider = new SkinProviderImpl(mainAbility.context);
      await repo.clear();
      await skinProvider.persist(SkinTheme.LIGHT);
      await skinProvider.persistLocale('zh');
    });

    it('navigates_searches_and_preserves_floating_layout', 0, async (): Promise<void> => {
      const rail = await component(driver, 'logs-commit-index-rail');
      const detail = await component(driver, 'logs-commit-detail');
      const sequence = await component(driver, 'logs-commit-sequence-0');
      const sequenceBounds = await sequence.getBounds();
      const railBounds = await rail.getBounds();
      const detailBounds = await detail.getBounds();

      expect(await sequence.getText()).assertEqual('#064');
      expect(railBounds.right - railBounds.left < 100).assertTrue();
      expect(sequenceBounds.left >= railBounds.right).assertTrue();

      const listBounds = await (await component(driver, 'logs-commit-list')).getBounds();
      const initialMarkerBounds = await (await component(driver, 'logs-commit-index-marker')).getBounds();
      const listX = Math.floor((listBounds.left + listBounds.right) / 2);
      await driver.drag(listX, listBounds.bottom - 20, listX, listBounds.top + 20, 800);
      await driver.delayMs(200);
      const scrolledMarkerBounds = await (await component(driver, 'logs-commit-index-marker')).getBounds();
      expect(scrolledMarkerBounds.top > initialMarkerBounds.top).assertTrue();

      await (await component(driver, 'logs-commit-index-tick-0')).click();
      await driver.delayMs(200);

      const railX = Math.floor((railBounds.left + railBounds.right) / 2);
      await driver.drag(railX, railBounds.top + 4, railX, railBounds.bottom - 4, 800);
      await driver.delayMs(200);
      expect(await (await component(driver, 'logs-commit-sequence-63')).getText()).assertEqual('#001');

      await (await component(driver, 'logs-commit-index-tick-0')).click();
      await driver.delayMs(200);
      expect(await (await component(driver, 'logs-commit-sequence-0')).getText()).assertEqual('#064');

      await openSearch(driver);
      const openRailBounds = await rail.getBounds();
      const openDetailBounds = await detail.getBounds();
      expect(sameBounds(railBounds, openRailBounds)).assertTrue();
      expect(sameBounds(detailBounds, openDetailBounds)).assertTrue();

      await search(driver, 'needle');
      expect(await (await component(driver, 'logs-search-result')).getText()).assertEqual('1 / 2');
      await closeSearch(driver);
      expect(await (await component(driver, 'logs-commit-content-0')).getText())
        .assertEqual('https://example.com/commit needle newest same day 中文');

      const urlBounds = await (await component(driver, 'logs-commit-content-0')).getBounds();
      await driver.click(urlBounds.left + 12, urlBounds.top + 12);
      expect(await (await component(driver, 'logs-url-popup')).isEnabled()).assertTrue();

      // The first outside click dismisses the auto-cancel URL popup; the second opens search.
      await (await component(driver, 'logs-search-toggle')).click();
      await driver.delayMs(100);
      await openSearch(driver);
      await search(driver, '#032');
      await closeSearch(driver);
      expect(await (await component(driver, 'logs-commit-sequence-32')).getText()).assertEqual('#032');

      await openSearch(driver);
      await (await component(driver, 'logs-search-date')).click();
      await component(driver, 'logs-date-picker');
      await (await component(driver, 'logs-date-confirm')).click();
      await driver.delayMs(200);
      expect(await (await component(driver, 'logs-search-result')).getText()).assertEqual(`${SAME_DATE} 1 / 2`);
      await (await component(driver, 'logs-search-next')).click();
      await closeSearch(driver);
      expect(await (await component(driver, 'logs-commit-content-1')).getText()).assertEqual('needle earlier same day');

      await openSearch(driver);
      await search(driver, 'absent');
      expect(await (await component(driver, 'logs-search-result')).getText()).assertEqual('未找到提交记录');
      const selectedBeforeClose = await (await component(driver, 'logs-commit-sequence-0')).getText();
      await closeSearch(driver);
      await openSearch(driver);
      expect(await (await component(driver, 'logs-search-input')).getText()).assertEqual('');
      await closeSearch(driver);
      expect(await (await component(driver, 'logs-commit-sequence-0')).getText()).assertEqual(selectedBeforeClose);

      await (await component(driver, 'nav-profile')).click();
      await (await component(driver, 'locale_button_en')).click();
      await openLogs(driver);
      await openSearch(driver);
      await search(driver, 'absent');
      expect(await (await component(driver, 'logs-search-result')).getText()).assertEqual('NO MATCHING COMMITS');
      await closeSearch(driver);

      await verifyTheme(driver, SkinTheme.LIGHT);
      await verifyTheme(driver, SkinTheme.DARK);
      await verifyTheme(driver, SkinTheme.PINK);
      await verifyTheme(driver, SkinTheme.PASTEL);
    });
  });
}
