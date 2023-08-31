; if IPSCCP determines a function returns undef,
; then the "returned" attribute of input arguments
; should be cleared.

; RUN: opt < %s -passes=ipsccp -S | FileCheck %s

; The only case that users of zapped functions are non-call site
; users is that they are blockaddr users. Skip them because we
; want to remove the returned attribute for call sites

; CHECK: {{define.*@blockaddr_user}}
define internal i32 @blockaddr_user(i1 %c, i32 returned %d) {
entry:
  br i1 %c, label %bb1, label %bb2

bb1:
  br label %branch.block

bb2:
  br label %branch.block

branch.block:
  %addr = phi ptr [blockaddress(@blockaddr_user, %target1), %bb1], [blockaddress(@blockaddr_user, %target2), %bb2]
  indirectbr ptr %addr, [label %target1, label %target2]

target1:
  br label %target2

; CHECK: ret i32 10
target2:
  ret i32 %d
}

define i32 @call_blockaddr_user(i1 %c) {
; CHECK-LABEL: define i32 @call_blockaddr_user(
; CHECK-NEXT: %r = call i32 @blockaddr_user(i1 %c
; CHECK-NEXT: ret i32 %r
  %r = call i32 @blockaddr_user(i1 %c, i32 returned 10)
  ret i32 %r
}
