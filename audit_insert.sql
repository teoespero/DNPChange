-- check the last ID
 select max(id) from DS_Global..Audit
 
 -- check if it exist
 select * from DS_Global..Audit where [description] = 'DNP flags changed from the prior month to this month'
 
-- insert the audit
insert into DS_Global..[Audit]
(
    id,
    [Grouping],
    [Description],
    [SQL],
    FilterId,
    Severity,
    IsForClient,
    AuditTargetId
)
values
(
    (select max(id)+1 from DS_Global..Audit),
    'PayrollNet',
    'DNP flags changed from the prior month to this month',
    'SELECT ( _.LastName + '', '' +_.FirstName + '' (Changed: True'' + '' - PayrollRun: '' + _.RunChanged + '')'') as [Description],    _.ReferenceKey as Id
     from (
    SELECT DISTINCT E.LastName,E.FirstName,E.ReferenceKey,(CASE WHEN EW.PyEmployeeId IS NULL THEN 0 ELSE 1 END) AS CurrentIsDeferred,PREVRRUN.IsDeferred,PR.[Description] AS RunChanged FROM PyEmployee E
    INNER JOIN PayrollRun PR ON Pr.Id = E.PayrollRunId
    LEFT JOIN PyEmployeeWithholding EW ON E.Id = EW.PyEmployeeId AND EW.PyWithholdingTypeId = 20
            INNER JOIN (
                SELECT DISTINCT E.LastName,E.FirstName,E.ReferenceKey,prevPR.DateToBePrinted,
                    CASE
                        WHEN EW.PyEmployeeId IS NULL THEN 0
                        ELSE 1
                    END AS IsDeferred
                FROM PyEmployee E
                INNER JOIN PayrollRun prevPR ON prevPR.Id = E.PayrollRunId
                LEFT JOIN PyEmployeeWithholding EW ON E.Id = EW.PyEmployeeId AND EW.PyWithholdingTypeId = 20      
                WHERE (datepart(month, prevPR.StartDate) =  datepart(month,dateadd(month, datediff(month, 0, getdate())-1, 0)) AND datepart(year, prevPR.StartDate) =  @2)
                )
            PREVRRUN ON E.ReferenceKey = PREVRRUN.ReferenceKey
    WHERE (datepart(month, PR.StartDate)= datepart(month,dateadd(month, datediff(month, 0, getdate()), 0)) AND datepart(year, PR.StartDate) =  @2)
        AND CASE
            WHEN EW.PyEmployeeId IS NULL
                THEN 0
            ELSE 1
            END != PREVRRUN.IsDeferred
    )
    AS _
    ORDER BY _.LastName',
    null,
    2,
    1,
    null
)
