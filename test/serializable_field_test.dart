import 'package:entity_sync/entity_sync.dart';
import 'package:test/test.dart';

void main() {
  test('Test IntegerField', () {
    final field = IntegerField('field');

    expect(field.isValid(null), null);
    expect(field.isValid(2.0), 2);
    expect(field.isValid(2.5), 2);
    expect(field.isValid('2'), 2);
    expect(field.isValid('2.5'), 2);
    expect(field.isValid(2), 2);
  });

  test('Test DoubleField', () {
    final field = DoubleField('field');

    expect(field.isValid(null), null);
    expect(field.isValid(2.0), 2.0);
    expect(field.isValid(2), 2.0);
  });

  test('Test StringField', () {
    final field = StringField('field');

    expect(field.isValid(null), null);
    expect(field.isValid('something'), 'something');
    expect(field.isValid(''), '');
  });

  test('Test DateTimeField', () {
    final field = DateTimeField('field');

    expect(field.isValid(null), null);

    final dateFromString = field.isValid('2020-09-09T03:30:33.058684Z');
    expect(dateFromString != null, true);
    if (dateFromString == null) {
      fail('dateFromString must not be null');
    }
    expect(dateFromString.year, 2020);
    expect(dateFromString.month, 9);
    expect(dateFromString.day, 9);

    final dateFromMillisEpoch = field.isValid(1620608288876);
    if (dateFromMillisEpoch == null) {
      fail('dateFromString must not be null');
    }
    expect(dateFromMillisEpoch.day, 10);
    expect(dateFromMillisEpoch.month, 5);
    expect(dateFromMillisEpoch.year, 2021);

    final now = DateTime.now();
    expect(field.isValid(now), now);
  });

  test('Test DateField', () {
    final field = DateField('field');

    expect(field.isValid(null), null);

    final dateFromString = field.isValid('2020-09-09T03:30:33.058684Z');
    expect(dateFromString != null, true);
    if (dateFromString == null) {
      fail('dateFromString must not be null');
    }
    expect(dateFromString.year, 2020);
    expect(dateFromString.month, 9);
    expect(dateFromString.day, 9);

    final dateFromMillisEpoch = field.isValid(1620608288876);
    if (dateFromMillisEpoch == null) {
      fail('dateFromString must not be null');
    }
    expect(dateFromMillisEpoch.day, 10);
    expect(dateFromMillisEpoch.month, 5);
    expect(dateFromMillisEpoch.year, 2021);

    final now = DateTime.now();
    expect(field.isValid(now), now);
  });

  test('Test BoolField', () {
    final field = BoolField('field');

    expect(field.isValid(null), null);
    expect(field.isValid(false), false);
  });
}
