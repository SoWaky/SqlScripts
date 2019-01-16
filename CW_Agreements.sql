SELECT Company.Company_Name, AGR_Type.AGR_Type_Desc AS AGR_Type, H.AGR_Name, AGR_Date_End, O.Owner_Level_Name AS [Location], BU.Description AS Department, SR_Board.Board_Name AS Board
		, D.Default_Flag AS AGR_Default, SR_Type.Description as Svc_Type, AGR_Cancel_Flag AS Cancelled, H.AGR_Amount, H.AGR_Notes
		--,* 
	FROM AGR_Default D
	INNER JOIN AGR_Header H
		ON D.AGR_Header_RecId = H.AGR_Header_RecId
	LEFT JOIN Owner_Level O
		ON O.Owner_Level_RecID = D.Owner_Level_RecID
	LEFT JOIN Billing_Unit BU
		ON BU.Billing_Unit_RecID = D.Billing_Unit_RecID
	LEFT JOIN SR_Type
		ON SR_Type.SR_Type_RecID = D.SR_Type_RecID
	LEFT JOIN SR_Board
		ON SR_Board.SR_Board_RecId = D.SR_Board_RecId
	LEFT JOIN AGR_Type
		ON AGR_Type.AGR_Type_RecId = H.AGR_Type_RecId
	LEFT JOIN Company
		ON Company.Company_RecId = H.Company_RecId
	ORDER BY 1,2,3,4,5,6,7