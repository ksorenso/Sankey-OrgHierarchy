/* 
 * This script builds the table csMetrics.dbo.tblOrgHierarchies
 *
 * tblOrgHierarchies is the source of the navigation hierarchy
 * each root node must have its hierarchy represented in this table
 * 
 * the root nodes:
 *	0 = Cisco Engineering
 *	4972 = SP Mobility Solutions
 *  4976 = SP Segment (SCMS)
 *  4977 =  Enterprise Segment (SCMS)
 *  5007 =  ECPS Segments (SCMS)
 */


USE [csMetrics]
GO

INSERT  INTO [dbo].[tblOrgHierarchies_bkup]
        ( [bkup_time]
        ,[root_org_id]
        ,[org_id]
        ,[org_level]
        ,[org_unique]
        ,[org_name]
        ,[org_name_ext]
        ,[org_depth]
        ,[parent_org_id]
        ,[parent_org_unique]
        ,[parent_org_name]
        ,[sort_order]
        ,[hierarchy_order]
        ,[children]
        ,[timestamp]
        )
        SELECT
            GETDATE() AS bkup_time
        ,   [root_org_id]
        ,   [org_id]
        ,   [org_level]
        ,   [org_unique]
        ,   [org_name]
        ,   [org_name_ext]
        ,   [org_depth]
        ,   [parent_org_id]
        ,   [parent_org_unique]
        ,   [parent_org_name]
        ,   [sort_order]
        ,   [hierarchy_order]
        ,   [children]
        ,   [timestamp]
        FROM
            dbo.tblOrgHierarchies

TRUNCATE TABLE dbo.tblOrgHierarchies

DECLARE @t1 TABLE
    (
     [root_org_id] INT
    ,[org_id] INT
    ,[org_level] NVARCHAR(255)
    ,[org_unique] NVARCHAR(255)
    ,[org_name] NVARCHAR(255)
    ,[org_name_ext] NVARCHAR(MAX)
    ,[org_depth] INT
    ,[parent_org_id] INT
    ,[parent_org_unique] NVARCHAR(255)
    ,[parent_org_name] NVARCHAR(255)
    ,[sort_order] INT
    ,[hierarchy_order] NVARCHAR(255)
    ,[children] INT
    ,[timestamp] DATETIME
    )

INSERT  INTO @t1
        ( [root_org_id]
        ,[org_id]
        ,[org_level]
        ,[org_unique]
        ,[org_name]
        ,[org_name_ext]
        ,[org_depth]
        ,[parent_org_id]
        ,[parent_org_unique]
        ,[parent_org_name]
        ,[sort_order]
        ,[hierarchy_order]
        ,[timestamp] 
        )
        SELECT
            tR.org_id root_org_id
        ,   X.[org_id]
        ,   X.[org_level]
        ,   X.[org_unique]
        ,   X.[org_name]
        ,   ISNULL(X.[org_name_ext], X.[org_name]) [org_name_ext]
        ,   X.[org_depth]
        ,   X.[parent_org_id]
        ,   X.[parent_org_unique]
        ,   X.[parent_org_name]
        ,   X.[sort_order]
        ,   CAST(tR.org_id AS NVARCHAR) + ':' + [hierarchy_order]
        ,   GETDATE()
        FROM
            csMetrics.dbo.tblOrgRoot tR
            CROSS APPLY (
                          SELECT
                            *
                          FROM
                            csMetrics.dbo.[ftblOrgHierarchy_NEW](csMetrics.dbo.fnGetDateIdToday(),
                                                              tR.org_id)
                        ) X
        WHERE
            ISNULL(tR.begin_date, '01/01/1900') <= CAST(GETDATE() AS DATE)
            AND ISNULL(tR.end_date, '12/31/2999') >= CAST(GETDATE() AS DATE) 



UPDATE
    t
SET
    t.children = x.children
FROM
    @t1 t
    INNER JOIN (
                 SELECT
                    tp.[org_id]
                 ,  COUNT(*) children
                 FROM
                    [csMetricsPf].[dbo].[t_sp_OrgHierarchy] tp
                    INNER JOIN csMetricsPf.dbo.t_sp_OrgHierarchy tc ON tp.org_id = tc.parent_org_id
                 GROUP BY
                    tp.org_id
               ) x ON t.org_id = x.org_id

INSERT  INTO [dbo].[tblOrgHierarchies]
        ( [root_org_id]
        ,[org_id]
        ,[org_level]
        ,[org_unique]
        ,[org_name]
        ,[org_name_ext]
        ,[org_depth]
        ,[parent_org_id]
        ,[parent_org_unique]
        ,[parent_org_name]
        ,[sort_order]
        ,[hierarchy_order]
        ,[children]
        ,[timestamp]
        )
        SELECT
            [root_org_id]
        ,   [org_id]
        ,   [org_level]
        ,   [org_unique]
        ,   [org_name]
        ,   [org_name_ext]
        ,   [org_depth]
        ,   [parent_org_id]
        ,   [parent_org_unique]
        ,   [parent_org_name]
        ,   [sort_order]
        ,   [hierarchy_order]
        ,   [children]
        ,   [timestamp]
        FROM
            @t1

SELECT
    *
FROM
    csMetrics.dbo.tblOrgHierarchies
	ORDER BY hierarchy_order
