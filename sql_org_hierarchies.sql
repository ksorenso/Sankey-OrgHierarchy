USE [csMetrics]
GO

/*
 *	Requires JSON.sql
 *    https://www.simple-talk.com/sql/t-sql-programming/producing-json-documents-from-sql-server-queries-via-tsql/
 *
 *	1. Run this script
 *	2. Take the output @MyHierarchy
 *	3. Validate here http://jsonlint.com/
 *  4. Incorporate into: F:\Data\www\books\d3-tips-n-tricks\simple-tree-from-flat-kls.html
 *  5. Start Python on F:\Data
 *  6. > python -m SimpleHTTPServer 8888 &.
 *  7. http://localhost:8888/
 */

DECLARE @links TABLE ( 
	[source] NVARCHAR(100),
	[target] NVARCHAR(100),
	[value] NVARCHAR(25)
)

DECLARE @nodes TABLE (
	[name] NVARCHAR(100)
)

INSERT INTO @links
        ( [source], [target], [value] )
SELECT 'tblOrg(csMetrics)', 'Script1', '1.0'
UNION
SELECT 'tblOrgName(csMetrics)', 'Script1', '1.0'
UNION
SELECT 'tblOrgParent(csMetrics)', 'Script1', '1.0'
UNION
SELECT 'tblOrgParent(csMetrics)', 'Script1', '1.0'
UNION
SELECT 'tblOrgRoot(csMetrics)', 'Script1', '1.0'
UNION
SELECT 'ftblOrgHierarchy_NEW(csMetrics)', 'Script1', '1.0'
UNION
SELECT 'Script1', 'tblOrgHierarchies.1', '1.0'

UNION
SELECT 'tblOrgHierarchies.1', 'sp_t_OrgPf_rejigger(Pf)', '1.0'
UNION
SELECT 'tPfActive#', 'sp_t_OrgPf_rejigger(Pf)', '1.0'
UNION
SELECT 'sp_t_OrgPf_tblBkgsOrg(Pf)', 'sp_t_OrgPf(Pf)', '1.0'
UNION
SELECT 'sp_t_OrgPf_BE_security(Pf)', 'sp_t_OrgPf(Pf)', '1.0'
UNION
SELECT 'sp_t_OrgPf_BE_cspg(Pf)', 'sp_t_OrgPf(Pf)', '1.0'
UNION
SELECT 'PF_MAP_IOT_20150723(Pf)', 'sp_t_OrgPf_BE_iot(Pf)', '1.0'
UNION
SELECT 'sp_t_OrgPf_BE_iot(Pf)', 'sp_t_OrgPf(Pf)', '1.0'
UNION
SELECT 'sp_t_OrgPf_SP_MBS(Pf)', 'sp_t_OrgPf(Pf)', '1.0'
UNION
SELECT 'sp_t_OrgPf_product_families(Pf)', 'sp_t_OrgPf(Pf)', '1.0'
UNION
SELECT 'sp_t_OrgPf_tblOrg(Pf)', 'sp_t_OrgPf(Pf)', '1.0'
UNION
SELECT 'sp_t_OrgPf_rejigger(Pf)', 'sp_t_Org(Pf)', '1.0'
UNION
SELECT 'sp_t_OrgPf(Pf)','sp_t_Org(Pf)', '1.0'
UNION
SELECT 'sp_t_Org(Pf)', 'spFinDataAutoComplete_part2b(Gbsbi)', '1.0'
UNION
SELECT 'spFinDataAutoComplete_part2b(Gbsbi)', 'tblOrgHierarchies.2', '1.0'


INSERT INTO @nodes
        ( name )
SELECT DISTINCT [name]
FROM (
SELECT [source] [name] FROM @links
UNION SELECT [target] FROM @links
)X

DECLARE @SankeyNodes NVARCHAR(MAX)
DECLARE @SankeyLinks NVARCHAR(MAX)
DECLARE @MyNodes Hierarchy
INSERT  INTO @MyNodes
        SELECT  *
        FROM    dbo.PARSEXML(
--your SQL Goes here --->
                             ( SELECT  name
                               FROM    @nodes
--you add this magic spell, making it XML, and giving a name for the 'list' of rows and the root
                             FOR
                               XML PATH('nodes') ,
                                   ROOT('nodes')
-- end of SQL	 
                             ))


SELECT @SankeyNodes = dbo.ToJSON(@MyNodes)
SELECT @SankeyNodes = RIGHT(@SankeyNodes, LEN(@SankeyNodes) - 4)


DECLARE @MyLinks Hierarchy
INSERT  INTO @MyLinks
        SELECT  *
        FROM    dbo.PARSEXML(
--your SQL Goes here --->
                             ( SELECT   
                                        [source],
     [target],
     [value]
                               FROM     @links
--you add this magic spell, making it XML, and giving a name for the 'list' of rows and the root
                             FOR
                               XML PATH('links') ,
                                   ROOT('links')
-- end of SQL	 
                             ))
SELECT @SankeyLinks = dbo.ToJSON(@MyLinks)
SELECT @SankeyLinks = LEFT(@SankeyLinks, LEN(@SankeyLinks) - 4) 

SELECT  @SankeyLinks  + ', ' + @SankeyNodes
