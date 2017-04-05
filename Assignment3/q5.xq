declare variable $dataset0 external;
declare variable $dataset1 external;
let $postings := $dataset0/postings
let $resumes := $dataset1/resumes
return
    <histogram>
        {
          for $sk in distinct-values($postings/posting/reqSkill/@what)
          return
              <skill name = '{ $sk }'>
                  {
                    for $i in 1 to 5
                    let $num := count($resumes//skill[@level=$i and @what=$sk])
                    return
                        <count level = '{ $i }'
                               n = '{ $num }' />
                  }
              </skill>
         }
    </histogram>
