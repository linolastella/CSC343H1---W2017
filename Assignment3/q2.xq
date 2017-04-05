declare variable $dataset0 external;
let $postings := $dataset0/postings
return
    <important>
        {
          $postings/posting[reqSkill/data(@importance * @level) =
                            max($postings//reqSkill/data(@importance * @level))]
         }
    </important>
