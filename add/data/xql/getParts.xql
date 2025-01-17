xquery version "3.1";
(:
 : For LICENSE-Details please refer to the LICENSE file in the root directory of this repository.
 :)

(: IMPORTS ================================================================= :)

import module namespace eutil = "http://www.edirom.de/xquery/util" at "../xqm/util.xqm";

(: NAMESPACE DECLARATIONS ================================================== :)

declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";

(: OPTION DECLARATIONS ===================================================== :)

declare option exist:serialize "method=text media-type=text/plain omit-xml-declaration=yes";

(: QUERY BODY ============================================================== :)

let $uri := request:get-parameter('uri', '')
let $mei := doc($uri)/root()

let $ret :=
    for $part in ($mei//mei:instrumentation/mei:instrVoice | $mei//mei:perfMedium//mei:perfRes)
    let $hasNoAttrSameas := not(exists($part/@sameas))
    return
        concat(
            '{label: "', eutil:getPartLabel($part, 'perfRes'),
            '", id:"', $part/@xml:id,
            '", selectedByDefault:', $hasNoAttrSameas,
            ', selected:', $hasNoAttrSameas, '}'
        )

return
    concat('[', string-join($ret, ','), ']')
