#!/bin/bash
target_path="$HOME/www/"
digest_path='/tmp/antigate_site_digests.txt'
host="$(basename $HOME)@sakura"
tmptext='/tmp/antigate_tmp.txt'
jsonfile='/tmp/antigate_upload.json'

cp -f $digest_path ${digest_path}.old

# hash check
hashcheck="$(/usr/local/bin/shasum -c $digest_path | grep FAILED)"
find $target_path -type f \( -name '*.php' -o -name '*.cgi' -o -name '*.shtml' -o -name '*.shtm' -o -name '.htaccess' \) -print0 | xargs -0 /usr/local/bin/shasum > $digest_path

diff="$(diff -u ${digest_path}.old $digest_path)"

rm -f ${digest_path}.old

date="$(date)"

printf '```\n---- %s %s ----\nSHA1 Check result:\n%s\n\n\nChanges:\n%s\n```' "$host" "$date" "$hashcheck" "$diff" > $tmptext

# build json file
echo "{\"channel\": \"#front-alert\", \"username\": \"${host}\", \"text\": \"" > $jsonfile
sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' $tmptext >> $jsonfile
echo "\", \"icon_emoji\": \":ghost:\"}" >> $jsonfile

if [ -n "$diff" ]; then
  /usr/local/bin/curl -X POST -H 'Content-type: application/json' https://hooks.slack.com/services/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 --data @"$jsonfile"
fi
