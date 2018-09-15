# General list operations.

with import ./trivial.nix;

rec {

  inherit (builtins)
    head
    tail
    length
    isList
    elemAt
    concatLists
    filter
    elem
    genList;

  /**
   * Create a list consisting of a single element.  `singleton x' is
   * sometimes more convenient with respect to indentation than `[x]'
   * when x spans multiple lines.
   */
  singleton = x: [ x ];

  /**
   * "Fold" a binary function `op' between successive elements of
   * `list' with `nul' as the starting value, i.e., `fold op nul [x_1
   * x_2 ... x_n] == op x_1 (op x_2 ... (op x_n nul))'.  (This is
   * Haskell's foldr).
   */
  fold = op: nul: list:
    let
      len = length list;
      fold' = n:
        if n == len then
          nul
        else
          op (elemAt list n) (fold' (n + 1));
    in
    fold' 0;

  /**
   * Left fold: `fold op nul [x_1 x_2 ... x_n] == op (... (op (op nul
   * x_1) x_2) ... x_n)'.
   */
  foldl = op: nul: list:
    let
      len = length list;
      foldl' = n:
        if n == -1 then
          nul
        else
          op (foldl' (n - 1)) (elemAt list n);
    in
    foldl' (length list - 1);

  /**
   * Strict version of foldl.
   */
  foldl' = builtins.foldl' or foldl;

  /** Map with index
   *
   * FIXME: why does this start to count at 1?
   *
   * imap (i: v: "${v}-${toString i}") ["a" "b"] == ["a-1" "b-2"]'.
   */
  imap = f: list: genList (n: f (n + 1) (elemAt list n)) (length list);

  /* Map and concatenate the result.

     Example:
       concatMap (x: [x] ++ ["z"]) ["a" "b"]
       => [ "a" "z" "b" "z" ]
  */
  concatMap = builtins.concatMap or (f: list: concatLists (map f list));

  /**
   * Flatten the argument into a single list; that is, nested lists are
   * spliced into the top-level lists.  E.g., `flatten [1 [2 [3] 4] 5]
   * == [1 2 3 4 5]' and `flatten 1 == [1]'.
   */
  flatten = x:
    if isList x then
      concatMap (y: flatten y) x
    else
      [ x ];

  # Remove elements equal to 'e' from a list.  Useful for buildInputs.
  remove = e: filter (x: x != e);

  /**
   * Find the sole element in the list matching the specified
   * predicate, returns `default' if no such element exists, or
   * `multiple' if there are multiple matching elements.
   */
  findSingle = pred: default: multiple: list:
    let
      found = filter pred list; len = length found;
    in
    if len == 0 then
      default
    else if len != 1 then
      multiple
    else
      head found;

  /**
   * Find the first element in the list matching the specified
   * predicate or returns `default' if no such element exists.
   */
  findFirst = pred: default: list:
    let
      found = filter pred list;
    in
    if found == [ ] then
      default
    else
      head found;

  /**
   * Return true only if function `pred' returns true for at least
   * element of `list'.
   */
  any = builtins.any or (pred: fold (x: y: if pred x then true else y) false);

  /**
   * Return true only if function `pred' returns true for all elements
   * of `list'.
   */
  all = builtins.all or (pred: fold (x: y: if pred x then y else false) true);

  /**
   * Count how many times function `pred' returns true for the elements
   * of `list'.
   */
  count = pred: foldl' (c: x: if pred x then c + 1 else c) 0;

  /**
   * Return a singleton list if true or an empty list if not true.
   *
   * Example:
   *   [ ] ++ optional (boolean argument) element)
   */
  optional = cond: elem:
    if cond then
      [ elem ]
    else
      [ ];

  /**
   * Return a list if true or an empty list if not true.
   *
   * Example:
   *   [ ] ++ optionals (boolean argument) [ element1 element2 ]
   */
  optionals = cond: elems:
    if cond then
      elems
    else
      [ ];

  /**
   * If argument is a list, return it; else, wrap it in a singleton
   * list.
   *
   * WARNING:
   *   If you're using this, you should almost certainly reconsider
   *   a more "well-typed" approach.
   *
   * Example:
   *   toList [ 1 2 ]
   *   => [ 1 2 ]
   *   toList "hi"
   *   => [ "hi "]
   */
  toList = x:
    if isList x then
      x
    else
      [ x ];

  /**
   * Return a list of integers from `first' up to and including `last'.
   *
   * Example:
   *   range 2 4
   *   => [ 2 3 4 ]
   *   range 3 2
   *   => [ ]
   */
   range = first: last:
     if first > last then
       [ ]
     else
       builtins.genList (n: first + n) (last - first + 1);

  /**
   * Partition the elements of a list in two lists, `right' and
   * `wrong', depending on the evaluation of a predicate.
   *
   * Example:
   *   partition (x: x > 2) [ 5 1 2 3 4 ]
   *   => { right = [ 5 3 4 ]; wrong = [ 1 2 ]; }
   */
  partition = builtins.partition or (pred:
    fold (h: t:
      if pred h then {
        right = [ h ] ++ t.right;
        wrong = t.wrong;
      } else {
        right = t.right;
        wrong = [ h ] ++ t.wrong; }
    ) {
      right = [ ];
      wrong = [ ];
    });

  /**
   * Merges two lists of the same size together. If the sizes aren't the same
   * the merging stops at the shortest. How both lists are merged is defined
   * by the first argument.
   *
   * Example:
   *   zipListsWith (a: b: a + b) ["h" "l"] ["e" "o"]
   *   => ["he" "lo"]
   */
  zipListsWith = f: fst: snd:
    builtins.genList
      (n: f (elemAt fst n) (elemAt snd n)) (min (length fst) (length snd));

  zipLists = zipListsWith (fst: snd: { inherit fst snd; });

  /**
   * Reverse the order of the elements of a list.
   *
   * Example:
   *   reverseList [ "b" "o" "j" ]
   *   => [ "j" "o" "b" ]
   */
  reverseList = xs:
    let
      l = length xs;
    in
    builtins.genList (n: elemAt xs (l - n - 1)) l;

  /**
   * Sort a list based on a comparator function which compares two
   * elements and returns true if the first argument is strictly below
   * the second argument.  The returned list is sorted in an increasing
   * order.  The implementation does a quick-sort.
   */
  sort = builtins.sort or (
    strictLess: list:
    let
      len = length list;
      first = head list;
      pivot' = n: acc@{ left, right }:
        let
          el = elemAt list n;
          next = pivot' (n + 1);
        in
        if n == len then
          acc
        else if strictLess first el then
          next {
            inherit left;
            right = [ el ] ++ right;
          }
        else
          next {
            left = [ el ] ++ left;
            inherit right;
          };
      pivot = pivot' 1 { left = []; right = []; };
    in
    if len < 2 then
      list
    else
      (sort strictLess pivot.left)
      ++ [ first ]
      ++  (sort strictLess pivot.right));

  /**
   * Return the first (at most) N elements of a list.
   *
   * Example:
   *   take 2 [ "a" "b" "c" "d" ]
   *   => [ "a" "b" ]
   *   take 2 [ ]
   *   => [ ]
   */
  take = count: sublist 0 count;

  /**
   * Remove the first (at most) N elements of a list.
   *
   * Example:
   *   drop 2 [ "a" "b" "c" "d" ]
   *   => [ "c" "d" ]
   *   drop 2 [ ]
   *   => [ ]
   */
  drop = count: list: sublist count (length list) list;

  /**
   * Return a list consisting of at most ‘count’ elements of ‘list’,
   * starting at index ‘start’.
   *
   * Example:
   *   sublist 1 3 [ "a" "b" "c" "d" "e" ]
   *   => [ "b" "c" "d" ]
   *   sublist 1 3 [ ]
   *   => [ ]
   */
  sublist = start: count: list:
    let
      len = length list;
    in
    genList (n: elemAt list (n + start)) (
        if start >= len then
          0
        else if start + count > len then
          len - start
        else
          count
      );

  /**
   * Return the last element of a list.
   */
  last = list:
    assert list != [ ];
    elemAt list (length list - 1);

  /**
   * Return all elements but the last
   */
  init = list:
    assert list != [ ];
    take (length list - 1) list;

  deepSeqList = xs: y:
    if any (x: deepSeq x false) xs then
      y
    else
      y;

  crossLists = f: foldl (fs: args: concatMap (f: map f args) fs) [ f ];

  /**
   * Remove duplicate elements from the list.
   *
   * O(n^2) complexity.
   */
  unique = list:
    if list == [ ] then
      [ ]
    else
      let
        x = head list;
        xs = unique (drop 1 list);
      in
      [ x ] ++ remove x xs;

  /**
   * Intersects list 'e' and another list.
   *
   * O(nm) complexity.
   */
  intersectLists = e: filter (x: elem x e);

  /**
   * Subtracts list 'e' from another list.
   *
   * O(nm) complexity.
   */
  subtractLists = e: filter (x: !(elem x e));

}
