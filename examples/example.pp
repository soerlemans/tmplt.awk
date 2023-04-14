<!doctype html>
<title>pp.awk example</title>
<ul>
#!
i=1
while test $i -le 10
do
	if test $((i % 2)) -eq 0
	then
		echo "	<li class=even>$i</li>"
	else
		echo "	<li class=odd>$i</li>"
	fi
	i=$((i + 1))
done
!#
</ul>