select *  FROM WF_NotifyActions where emailfrom is not null or Specific_Email is not null
select *  FROM WF_NotifyAction_Emails where Contact_RecID in (select Contact_RecID from Contact where Inactive_Flag = 1)
select *  FROM SR_Workflow where Member_RecID in (select Member_RecID from member where Inactive_Flag = 1)
