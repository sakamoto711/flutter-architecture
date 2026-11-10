import "package:flutter_architecture/common/class/struct/group.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("空・単一・複数の組み合わせで結合と重複除去の契約を維持する", () {
    const inputs = <List<int>>[
      [],
      [1],
      [1, 1],
      [1, 2],
      [2, 2, 1],
    ];
    for (final left in inputs) {
      for (final right in inputs) {
        for (final distinct in [false, true]) {
          final combined = [...left, ...right];
          final expected = distinct ? combined.toSet().toList() : combined;
          final actual = Group.from(left).merge(other: Group.from(right), distinct: distinct);
          expect(actual.values, expected);
          expect(actual, Group.from(expected));
        }
      }
    }
  });

  test("重複を除いた結果が1要素なら左右どちらの結合順でもSingleGroupになる", () {
    final single = Group.single(1);
    final repeated = Group.from([1, 1]);
    expect(single.merge(other: repeated, distinct: true), const SingleGroup(1));
    expect(repeated.merge(other: single, distinct: true), const SingleGroup(1));
  });

  test("作成元を変更してもグループの値と等価性を維持する", () {
    final original = [1, 2];
    final group = Group.from(original);
    final expected = Group.from([1, 2]);
    original.clear();
    expect(group.values, [1, 2]);
    expect(group, expected);
    expect(() => (group.values as List<int>).clear(), throwsUnsupportedError);
  });
}
