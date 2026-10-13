#!/usr/bin/env bash
# Turns versions.json into the list of images to build, in the spirit of the
# Docker Library's versions.json + generate-stackbrew-library.sh tooling.
#
# Usage:
#   ./generate.sh matrix [all|releases|source]   GitHub Actions build matrix (JSON)
#   ./generate.sh tags                           Supported tags list (Markdown)
#   ./generate.sh readme                         Rewrite the tags list in README.md
#
# Floating tags are worked out from the version numbers, per tag suffix: the
# newest 0.9.3.x gets "0.9.3", the newest 0.9.x gets "0.9", and the newest of
# all gets "latest" (or just the suffix, e.g. "screen", for suffixed variants).
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

GITHUB_URL='https://github.com/soup-bowl/opensimulator-docker'
CONTEXT='image'

builds() {
	jq --arg context "$CONTEXT" '
		. as $root
		| def vkey: split(".") | map(tonumber);
		def variant($name):
			$root.variants[$name] // error("versions.json: unknown variant \"\($name)\"");

		[
			$root.versions | to_entries[] | .key as $version | .value.variants[]
			| { version: $version, variant: ., suffix: (variant(.).suffix // "") }
		] as $releases
		| [
			$releases[] as $b
			| ($releases | map(select(.suffix == $b.suffix) | .version)) as $peers
			| ($b.version | split(".")) as $parts
			| (
				[$b.version]
				+ ([range(2; $parts | length) as $n | $parts[:$n] | join(".")
					| select(. as $p | $peers | map(select(startswith($p + "."))) | max_by(vkey) == $b.version)
				] | reverse)
				+ (if ($peers | max_by(vkey)) == $b.version then ["latest"] else [] end)
			) as $aliases
			| variant($b.variant) as $v
			| {
				kind: "release",
				version: $b.version,
				variant: $b.variant,
				tags: [$aliases[] | if $b.suffix == "" then . elif . == "latest" then $b.suffix else "\(.)-\($b.suffix)" end],
				dockerfile: $v.dockerfile,
				target: $v.target,
				platforms: ($root.versions[$b.version].platforms // $v.platforms),
				test: ($v.test != false)
			}
		]
		+ (
			$root.source // empty
			| variant(.variant) as $v
			| [{
				kind: "source",
				version: .ref,
				variant: .variant,
				tags: [.tag],
				dockerfile: $v.dockerfile,
				target: $v.target,
				platforms: (.platforms // $v.platforms),
				test: ($v.test != false)
			}]
		)
		| map(. + { context: $context })
	' versions.json
}

case "${1:-}" in
	matrix)
		scope="${2:-all}"
		case "$scope" in
			all | releases | source) ;;
			*) echo >&2 "error: unknown scope '$scope' (expected all, releases or source)"; exit 1 ;;
		esac
		builds | jq -c --arg scope "$scope" --slurpfile root versions.json '
			map(
				select($scope == "all" or (.kind == "release" and $scope == "releases") or (.kind == $scope))
				| . as $b
				| {
					name: "\(.version) (\(.variant))",
					version,
					context,
					dockerfile,
					target,
					test,
					platforms: (.platforms | join(",")),
					tags: ([$root[0].registries[] as $r | $b.tags[] | "\($r):\(.)"] | join(","))
				}
			)
			| { include: . }
		'
		;;

	tags)
		builds | jq -r --arg url "$GITHUB_URL" '
			.[] | "-\t[\(.tags | map("`\(.)`") | join(", "))](\($url)/blob/main/\(.context)/\(.dockerfile))\n"
		'
		;;

	readme)
		list="$("$0" tags)"
		awk -v list="$list" '
			/<!-- tags:start -->/ { print; print ""; print list; print ""; skip = 1; next }
			/<!-- tags:end -->/ { skip = 0 }
			!skip
		' README.md > README.md.tmp
		mv README.md.tmp README.md
		;;

	*)
		sed -n '5,8s/^# \{0,1\}//p' "$0" >&2
		exit 1
		;;
esac
