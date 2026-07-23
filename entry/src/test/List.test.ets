import localUnitTest from './LocalUnit.test';
import domainEntityTest from './DomainEntity.test';
import checkInRepoTest from './CheckInRepo.test';
import recordCheckInTest from './RecordCheckIn.test';
import loadHeatmapTest from './LoadHeatmap.test';
import skinProviderTest from './SkinProvider.test';
import heatmapVMTest from './HeatmapVM.test';
import frequencyPatternEngineTest from './FrequencyPatternEngine.test';
import soundPlayerTest from './SoundPlayer.test';
import loadActivityTest from './LoadActivity.test';
import debugRuntimeTest from './DebugRuntime.test';
import learnedPatternPolicyTest from './LearnedPatternPolicy.test';
import manageLearnedPatternsTest from './ManageLearnedPatterns.test';
import analyzePendingObservationsTest from './AnalyzePendingObservations.test';
import uiLabelsTest from './UILabels.test';

export default function testsuite() {
  localUnitTest();
  domainEntityTest();
  checkInRepoTest();
  recordCheckInTest();
  loadHeatmapTest();
  skinProviderTest();
  heatmapVMTest();
  frequencyPatternEngineTest();
  soundPlayerTest();
  loadActivityTest();
  debugRuntimeTest();
  learnedPatternPolicyTest();
  manageLearnedPatternsTest();
  analyzePendingObservationsTest();
  uiLabelsTest();
}
