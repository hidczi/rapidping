#!/bin/bash 


# This is a bash script that turns ping for Linux into a "rapid ping" like Cisco or Juniper. 

rm /tmp/rapid.tmp


rapid=0
count=5
size=56
ipadd=${!#}
ippat="\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}\b"
y=0
n=0

# changes behavior of the "trap", depending on the presence or absence of responses from the investigated address

fortrap () {

	if [[ "$rapid" -ne 0 ]]; then
		if [[ "$n" == "$i" ]]; then																							
			echo -e "\r"
				tail -n 3 /tmp/rapid.tmp | sed -e '2s/^1/'$n'/;2s/+1/+'$n'/'
				rm /tmp/rapid.tmp
				exit 1   
		else
			echo -e "\r"
			rtt
		fi
	fi
}

trap 'fortrap' 2

usage () {

	echo -e "use like this: ping [-c(count, default=5) -s(size(bytess) default=56) -r(rapid)] ip addres(X.X.X.X)"
	echo "to use normal ping add backslash before the command: \ping [...] ip addres" 
}

if [ "$#" -lt 1 ]; then
	echo "ping: error"
	usage
	exit 1
fi

if [[ "$#" == 1 ]]; then
	if [[ "$1" == -h ]]; then
 		usage
 		exit 0
 	fi
fi


# sent one packet at a time the specified number of times, depending on the answer or lack of it, the terminal 
# displays "!" or "." respectively, and count the number of positive and negative responses to compute rtt

rping () {

	if [[ -e /tmp/rping.tmp ]]; then
		rm /tmp/rapid.tmp
	fi

	for (( i = 0; i < $count; i++ )); do 
		if ((i != 0 && i % 70 == 0)); then
			echo -e "\r"
		fi
		ping -n -c 1 -W 1 -q -s "$size" "$dst" >> /tmp/rapid.tmp
		if [[ $(echo $?) -eq 0 ]]; then
			if [[ "$i" == 0 ]]; then
				echo $(grep -m 1 'PING*' /tmp/rapid.tmp)
			fi
			echo -ne '!'
			((y++))
		else
			if [[ "$i" == 0 ]]; then
				echo "PING "$dst" ("$dst") "$size"($((size + 28))) bytes of data."
			fi
			echo -ne '.'
			((n++))
			if ((n == count)); then
				echo -e "\r"
				tail -n 3 /tmp/rapid.tmp | sed -e '2s/1/'$n'/;2s/+1/+'$n'/'
				exit 1
			fi
		fi
	done
	echo -e "\r"

	rtt
	rm /tmp/rapid.tmp
}

# read rtt based on data from /tmp/rapid.tmp and print to terminal

rtt () {
	
	durat=$(echo "$SECONDS * 1000" | bc)
	rttpat="([[:digit:]]+\.[[:digit:]]{3}/?){3}"
	min=$(egrep -o $rttpat /tmp/rapid.tmp | cut -d '/' -f 1 | sort -nk1 | head -n 1)
	max=$(egrep -o $rttpat /tmp/rapid.tmp | cut -d '/' -f 1 | sort -nk1 | tail -n 1)

	avg=(`egrep -o $rttpat /tmp/rapid.tmp | cut -d '/' -f 1 | sort -nk1`)
	cavg=${#avg[@]}
	sumavg=$(echo "${avg[@]}" | sed 's/ / \+ /g')
	finavg=$(echo "scale=3; ("$sumavg") / "$cavg"" | bc -l)

	mdev=$(for (( i = 0; i < cavg; i++ )); do echo "(${avg[$i]} - (("$sumavg") / "$cavg"))^2 + "; done)
	mdev=$(echo "sqrt((${mdev%???}) / "$cavg")")
	mdev=$(echo "scale=3; x="$mdev";  if(x<1) print 0; x" | bc -l --mathlib)

	loss=$(echo "100 - ($y * 100 / $count)" | bc)

	echo "$(grep -m 1 '\-\-\-' /tmp/rapid.tmp)"
	echo ""$i" packets transmitted, "$y" received, $n packet loss, time "$durat"ms"
   	echo "rtt min/avg/max/mdev = $min/$avg/$max/$mdev ms"
	exit 0
}

# I've never had to use "-r" in ping, so I use it to activate "rapid"
# the "-c" and "-s" options are the same as the original ping command

while [[ -n "$1" ]]; do
	case "$1" in
		-c)					shift
							count="$1"
							;;
		-s)					shift
							size="$1"
							;;
 		"$ipadd")				shift
							dst="$ipadd"
							;;
		-r)					rapid=1
							;;
		*)					echo "error: \""$1"\" invalid value"
							usage >&2
							exit 1
							;;
					
	esac
	shift
done

if [[ ! "$ipadd" =~ $ippat ]]; then
	echo -e "\n\""$ipadd"\" invalid value for ip addres." >&2
	usage >&2
	exit 1
fi

if [[ ! "$count" =~ [1-9]+[0-9]? ]]; then
	echo -e "\n\""$count"\" bad number of packets to transmit." >&2
	usage >&2
	exit 1
fi

if [[ ! "$size" =~ [0-9]+ ]]; then
	echo -e "\n\""$size "\" invalid value for size." >&2
	usage >&2
	exit 1
fi

if [[ "$rapid" == 0 ]]; then
	ping -c "$count" -s "$size" "$dst"
	exit 0
else
	SECONDS=0
	rping
fi
