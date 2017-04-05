declare variable $dataset0 external;
let $resumes := $dataset0/resumes
return
    <qualified>
        {
          for $res in $resumes/resume
          let $num_sk := count($res/skills/skill)
          where $num_sk > 3
          return
              <candidate
                  rid = '{ $res/@rID }'
                  numskills = '{ $num_sk }'
                  citizenzhip = '{ $res/identification/citizenship/text() }'>
                      <name>
                         { $res/identification/name/forename/text() }
                      </name>
              </candidate>
         }
    </qualified>
    
