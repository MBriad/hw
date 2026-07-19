import localUnitTest from './LocalUnit.test';
import domainEntityTest from './DomainEntity.test';

export default function testsuite() {
  localUnitTest();
  domainEntityTest();
}