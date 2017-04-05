declare variable $dataset0 external;
declare variable $dataset1 external;
let $interviews := $dataset0/interviews
let $resumes := $dataset1/resumes
return
    <bestskills>
        {
          for $int in $interviews/interview
          let $highest := max($int/assessment/*[name(self::*) != "answers" and
                                                name(self::*) != "techProficiency"])
          let $skills := $int//(communication|enthusiasm|collegiality)[. = $highest]
          for $skill in $skills
          let $student := $resumes/resume[@rID = $int/@rID]//name/forename
          let $post := $int/@pID
          return
              <best resume = '{ $student }'
                    position = '{ $post }'>
                    { $skill }
              </best>
         }
    </bestskills>
