class ModeratedPost < ModeratedFlag 

  belongs_to :post, :foreign_key => 'foreign_id'
end
