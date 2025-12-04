/*
Family Tree Program in Prolog
--------------------------------
Facts: parent/2, male/1, female/1
Derived rules: grandparent/2, sibling/2, cousin/2, ancestor/2, descendant/2
Helper predicates for convenient list queries.
Tested with SWI-Prolog.

Usage (SWI-Prolog):
?- [family_tree].
?- children_of(adam, Cs).
?- sibling(edward, fiona).
?- cousin(jack, oliver).
?- grandparent(adam, jack).
?- descendants_of(adam, Ds).

*/

% ----------- Basic facts -----------
male(adam).
female(beth).

male(charles).
female(diana).

male(edward).
female(fiona).

male(george).
female(helen).

male(jack).
female(kelly).
female(mia).

male(oliver).
female(quinn).

female(isabel).
male(liam).
female(nora).
male(peter).

% parent(Parent, Child).
% Gen 1 -> Gen 2
parent(adam, edward).
parent(beth, edward).
parent(adam, fiona).
parent(beth, fiona).

parent(charles, george).
parent(diana,  george).
parent(charles, helen).
parent(diana,  helen).

% Gen 2 -> Gen 3
parent(edward, jack).
parent(isabel, jack).
parent(edward, kelly).
parent(isabel, kelly).

parent(fiona, mia).
parent(liam,  mia).

parent(george, oliver).
parent(nora,   oliver).

parent(helen, quinn).
parent(peter, quinn).

% ----------- Derived relationships -----------

% sibling(X,Y): X and Y share at least one parent, and are not the same person.
sibling(X, Y) :-
    parent(P, X),
    parent(P, Y),
    X \= Y.

% cousin(X,Y): parents of X and Y are siblings; X and Y are distinct.
cousin(X, Y) :-
    parent(PX, X),
    parent(PY, Y),
    sibling(PX, PY),
    X \= Y.

% Recursive definition of the Nth ancestor.
% nth_ancestor(Anc, Desc, N): Anc is the Nth ancestor of Desc.
nth_ancestor(Anc, Desc, 1) :-
    parent(Anc, Desc).
nth_ancestor(Anc, Desc, N) :-
    N > 1,
    parent(Anc0, Desc),
    N1 is N - 1,
    nth_ancestor(Anc, Anc0, N1).

% grandparent(X,Y): X is the 2nd ancestor of Y (demonstrates recursion via nth_ancestor/3).
grandparent(X, Y) :-
    nth_ancestor(X, Y, 2).

% A general recursive ancestor relation (reflexive-transitive not included by default).
ancestor(Anc, Desc) :-
    parent(Anc, Desc).
ancestor(Anc, Desc) :-
    parent(Anc0, Desc),
    ancestor(Anc, Anc0).

% descendant(Anc, Desc): Desc is a descendant of Anc.
descendant(Anc, Desc) :-
    parent(Anc, Desc).
descendant(Anc, Desc) :-
    parent(Anc, Mid),
    descendant(Mid, Desc).

% ----------- Convenience predicates (for queries that return lists) -----------

% children_of(Parent, ChildrenList).
children_of(P, Children) :-
    findall(C, parent(P, C), Cs),
    sort(Cs, Children).

% siblings_of(Person, SiblingsList) -- excludes the person themself.
siblings_of(X, Sibs) :-
    findall(Y, sibling(X, Y), Ys),
    sort(Ys, Sibs).

% cousins_of(Person, CousinsList) -- excludes the person themself.
cousins_of(X, Cousins) :-
    findall(Y, cousin(X, Y), Ys),
    sort(Ys, Cousins).

% descendants_of(Ancestor, DescendantsList).
descendants_of(A, Ds) :-
    setof(D, descendant(A, D), Ds), !.
descendants_of(_, []).  % If no descendants, return empty list instead of failing.
