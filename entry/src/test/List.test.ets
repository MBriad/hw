import localUnitTest from './LocalUnit.test';
import domainEntityTest from './DomainEntity.test';
import checkInRepoTest from './CheckInRepo.test';
import recordCheckInTest from './RecordCheckIn.test';
import loadHeatmapTest from './LoadHeatmap.test';
import skinProviderTest from './SkinProvider.test';
import heatmapVMTest from './HeatmapVM.test';
import keywordMatcherTest from './KeywordMatcher.test';
import detectEasterEggTest from './DetectEasterEgg.test';
import soundPlayerTest from './SoundPlayer.test';
import loadActivityTest from './LoadActivity.test';
import debugRuntimeTest from './DebugRuntime.test';

export default function testsuite() {
  localUnitTest();
  domainEntityTest();
  checkInRepoTest();
  recordCheckInTest();
  loadHeatmapTest();
  skinProviderTest();
  heatmapVMTest();
  keywordMatcherTest();
  detectEasterEggTest();
  soundPlayerTest();
  loadActivityTest();
  debugRuntimeTest();
}
