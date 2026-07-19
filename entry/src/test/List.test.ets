import localUnitTest from './LocalUnit.test';
import domainEntityTest from './DomainEntity.test';
import checkInRepoTest from './CheckInRepo.test';
import recordCheckInTest from './RecordCheckIn.test';
import loadHeatmapTest from './LoadHeatmap.test';
import skinProviderTest from './SkinProvider.test';
import heatmapVMTest from './HeatmapVM.test';

export default function testsuite() {
  localUnitTest();
  domainEntityTest();
  checkInRepoTest();
  recordCheckInTest();
  loadHeatmapTest();
  skinProviderTest();
  heatmapVMTest();
}