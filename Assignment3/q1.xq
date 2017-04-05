declare variable $dataset0 external;
let $postings := $dataset0/postings
return
    <dbjobs>
        {
          for $p in $postings/posting
          where $p/reqSkill[@what="SQL" and @level=5]
          return $p
         }
    </dbjobs>
