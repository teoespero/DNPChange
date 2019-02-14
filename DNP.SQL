SELECT 
	('Processing: '+(SELECT Description FROM PayrollRun WHERE [Description] = 'FEB 2019')+_.LastName + ', ' + _.FirstName + ' (Changed: True' + ' - PayrollRun: ' + _.RunChanged + ')') AS [Description],
       _.ReferenceKey AS Id
FROM (SELECT DISTINCT
  E.LastName,
  E.FirstName,
  E.ReferenceKey,
  E.PayrollRunId,
  E.Id,
  (CASE
    WHEN EW.PyEmployeeId IS NULL THEN 0
    ELSE 1
  END) AS CurrentIsDeferred,
  PREVRRUN.IsDeferred,
  PR.[Description] AS RunChanged
FROM PyEmployee E
INNER JOIN PayrollRun PR
  ON Pr.Id = E.PayrollRunId
  AND pr.PayrollRunTypeId = 1
  AND E.PayrollRunId = (SELECT Id FROM PayrollRun WHERE [Description] = 'FEB 2019')
LEFT JOIN PyEmployeeWithholding EW
  ON E.Id = EW.PyEmployeeId
  AND EW.PyWithholdingTypeId = 20
INNER JOIN (SELECT DISTINCT
  E.LastName,
  E.FirstName,
  E.ReferenceKey,
  prevPR.DateToBePrinted,
  CASE
    WHEN EW.PyEmployeeId IS NULL THEN 0
    ELSE 1
  END AS IsDeferred
FROM PyEmployee E
INNER JOIN PayrollRun PR
  ON Pr.Id = E.PayrollRunId
  and pr.PayrollRunTypeId = 1
INNER JOIN PayrollRun prevPR
  ON prevPR.Id = E.PayrollRunId 
  and prevPR.PayrollRunTypeId = 1
LEFT JOIN PyEmployeeWithholding EW
  ON E.Id = EW.PyEmployeeId
  AND EW.PyWithholdingTypeId = 20
  AND EW.PayrollRunId IN (SELECT
    Id
  FROM PayrollRun
  WHERE PayrollRunTypeId = 1)
WHERE (prevPR.StartDate) = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)
AND prevpr.PayrollRunTypeId = 1) PREVRRUN
  ON E.ReferenceKey = PREVRRUN.ReferenceKey
WHERE PR.StartDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
AND pr.PayrollRunTypeId = 1
AND
   CASE
     WHEN EW.PyEmployeeId IS NULL THEN 0
     ELSE 1
   END != PREVRRUN.IsDeferred) AS _
ORDER BY _.LastName
