#!/bin/sh

test_description='tracking branch update checks for git push'

. ./test-lib.sh

test_expect_success 'setup' '
	echo 1 >file &&
	git add file &&
	git commit -m 1 &&
	git branch b1 &&
	git branch b2 &&
	git branch b3 &&
	git clone . aa &&
	git checkout b1 &&
	echo b1 >>file &&
	git commit -a -m b1 &&
	git checkout b2 &&
	echo b2 >>file &&
	git commit -a -m b2
'

test_expect_success 'prepare pushable branches' '
	cd aa &&
	b1=$(git rev-parse origin/b1) &&
	b2=$(git rev-parse origin/b2) &&
	git checkout -b b1 origin/b1 &&
	echo aa-b1 >>file &&
	git commit -a -m aa-b1 &&
	git checkout -b b2 origin/b2 &&
	echo aa-b2 >>file &&
	git commit -a -m aa-b2 &&
	git checkout master &&
	echo aa-master >>file &&
	git commit -a -m aa-master
'

test_expect_success 'mixed-success push returns error' '
	cd aa &&
	test_must_fail git push origin :
'

test_expect_success 'check tracking branches updated correctly after push' '
	cd aa &&
	test "$(git rev-parse origin/master)" = "$(git rev-parse master)"
'

test_expect_success 'check tracking branches not updated for failed refs' '
	cd aa &&
	test "$(git rev-parse origin/b1)" = "$b1" &&
	test "$(git rev-parse origin/b2)" = "$b2"
'

test_expect_success 'deleted branches have their tracking branches removed' '
	cd aa &&
	git push origin :b1 &&
	test "$(git rev-parse origin/b1)" = "origin/b1"
'

test_expect_success 'already deleted tracking branches ignored' '
	cd aa &&
	git branch -d -r origin/b3 &&
	git push origin :b3 >output 2>&1 &&
	! grep "^error: " output
'

test_done
