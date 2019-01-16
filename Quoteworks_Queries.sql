-- Run these queries in the Quotewerks MS Access database (in Visual Studio)
-- Provider=Microsoft.Jet.OLEDB.4.0;Data Source=W:\QuoteWerks\docs.mdb

SELECT DocStatus, COUNT(*) AS Expr1
	FROM DocumentHeaders
	GROUP BY DocStatus

SELECT ProjectNo, SoldToCompany, PreparedBy, DocDate, ExpirationDate, DocName, GrandTotal, ProfitAmount, DocStatus
	FROM DocumentHeaders
	WHERE (DocStatus = 'Open')
	ORDER BY 1, 2