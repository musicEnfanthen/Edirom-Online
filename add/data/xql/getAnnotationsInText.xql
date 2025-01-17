xquery version "3.1";
(:
 : For LICENSE-Details please refer to the LICENSE file in the root directory of this repository.
 :)

(:~
    Returns a JSON sequence with all anotations in a specific text.

    @author <a href="mailto:roewenstrunk@edirom.de">Daniel Röwenstrunk</a>
:)

(: NAMESPACE DECLARATIONS ================================================== :)

declare namespace ft = "http://exist-db.org/xquery/lucene";
declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";

(: OPTION DECLARATIONS ===================================================== :)

declare option exist:serialize "method=text media-type=text/plain omit-xml-declaration=yes";

(:~
    Finds all annotations in all works.

    @param $elems The elements to check (most likely measures and zones)
    @returns A sequence of annotation elements
:)
declare function local:findAnnotations($uri as xs:string) as element()* {
    
    (: TODO: check if annotations hold URIs or IDRefs :)
    collection('/db/contents')//mei:annot[matches(@plist, $uri)]
};

declare function local:getAnnotations($uriSharp as xs:string, $annotations as element()*) as xs:string* {
    for $annotation in $annotations
    let $id := $annotation/string(@xml:id)
    let $uri := concat('xmldb:exist://', document-uri($annotation/root()), '#', $id)
    let $prio := $annotation/mei:ptr[@type = "priority"]/replace(@target, '#', '')
    let $cat := $annotation/mei:ptr[@type = "categories"]/replace(@target, '#', '')
    let $plist :=
        for $p in tokenize($annotation/@plist, '\s+')
        return
            if (starts-with($p, $uriSharp)) then
                (concat('{id:"', $id, '__', substring-after($p, $uriSharp), '"}'))
            else
                ()
    let $plist := string-join($plist, ',')
    return (: TODO map instead of concat :)
        concat('
           	{',
            'id: "', $id, '", ',
            'plist: [', $plist, '], ',
            'svgList: [], ',
            'fn: "loadLink(\"', $uri, '\")", ',
            'uri: "', $uri, '", ',
            'priority: "', $prio, '", ',
            'categories: "', $cat, '"',
            '}'
        )
};

let $uri := request:get-parameter('uri', '')
let $uriSharp := concat($uri, '#')
let $annotations := local:findAnnotations($uri)

return (: TODO map instead of concat :)
    concat(
        '[',
        string-join(local:getAnnotations($uriSharp, $annotations), ','),
        ']'
    )
