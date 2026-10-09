import 'package:beautiful_tracker/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('email', () {
    expect(Validators.email(''), 'Email is required');
    expect(Validators.email('kevin@'), 'Enter a valid email address');
    expect(Validators.email('a b@x.io'), 'Enter a valid email address');
    expect(Validators.email(' kevin@pace.dev '), isNull);
  });

  test('password', () {
    expect(Validators.password(''), 'Password is required');
    expect(
      Validators.password('12345'),
      'Password must be at least 6 characters',
    );
    expect(Validators.password('123456'), isNull);
  });

  test('name', () {
    expect(Validators.name('   '), 'Name is required');
    expect(Validators.name('Kevin'), isNull);
  });

  test('confirmPassword compares with the current password value', () {
    var password = 'secret1';
    final validate = Validators.confirmPassword(() => password);
    expect(validate('secret1'), isNull);
    password = 'changed';
    expect(validate('secret1'), 'Passwords do not match');
  });
}
