
SET DEFINE OFF;

CREATE OR REPLACE PROCEDURE DW.P_ENVIAR_MAIL_ACTIVIDAD_DIARIA AS
/*
        v5.1    02-02-2016      Se agrega actividad: "PACIENTES NO ATENDIDOS URGENCIA"
        v5.2    07-02-2018      Se agrega apertura DIAS CAMA por Servicio  a solicitud de JSABAJ
*/

V_ENCABEZADO VARCHAR2(32767);
V_CUERPO VARCHAR2(32767);
V_MENSAJE CLOB := ' '; 
V_PIE VARCHAR2(32767);
V_NDIA NUMBER(2);

BEGIN
            /*ESTABLECE HASTA QUE DIA MOSTRAR:*/
            SELECT TO_NUMBER(TO_CHAR(SYSDATE-1,'DD')) INTO V_NDIA FROM DUAL;

            V_ENCABEZADO := '<!DOCTYPE HTML>
                                                                <html>
                                                                    <head>
                                                                        <style type="text/css">.datagrid table { border-collapse: collapse; text-align: left; width: 100%; } .datagrid {font: normal 12px/150% Verdana, Helvetica, Arial sans-serif; background: #fff; overflow: hidden; border: 1px solid #006699; -webkit-border-radius: 3px; -moz-border-radius: 3px; border-radius: 3px; }.datagrid table td, .datagrid table th { padding: 3px 10px; }
                                                                        .datagrid table thead th, .diasAbajo {background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #006699), color-stop(1, #00557F) );background:-moz-linear-gradient( center top, #006699 5%, #00557F 100% );filter:progid:DXImageTransform.Microsoft.gradient(startColorstr="#006699", endColorstr="#00557F");background-color:#006699; color:#FFFFFF; font-size: 15px; font-weight: bold; border-left: 1px solid #0070A8; }.datagrid table thead th:first-child{ border: none; }.datagrid table tbody td { color: #00557F; border-left: 1px solid #E1EEF4;font-size: 15px;font-weight: normal; }.datagrid table tbody .alt td { background: #E1EEF4; color: #00557F; }.datagrid table tbody td:first-child { border-left: none; }.datagrid table tbody tr:last-child td { border-bottom: none; }</style>
                                                                    <title>Actividad Diaria Clinica Vespucio</title>
                                                                    </head>
                                                                    <body>';
            V_ENCABEZADO := V_ENCABEZADO||' '|| '<p style="font-family: Verdana, Helvetica, Arial sans-serif;">Estimad@s,</p>';
            V_ENCABEZADO := V_ENCABEZADO||' '|| '<p style="font-family: Verdana, Helvetica, Arial sans-serif;">Les informamos que la actividad del mes, hasta el dia de ayer es la siguiente:</p>  ';
                                   
            V_ENCABEZADO := V_ENCABEZADO||' '||'<div class="datagrid">
                                                                    <table>
                                                                      <thead>
                                                                        <tr>
                                                                            <th colspan="'||(V_NDIA +2) ||'" ALIGN="center" style="font-family: Verdana, Helvetica, Arial sans-serif;" >'||TO_CHAR(SYSDATE-1,'MONTH')||' '|| TO_CHAR(SYSDATE-1,'YYYY')||'</th>
                                                                        </tr>
                                                                        <tr>
                                                                          <th ALIGN="center" rowspan="2"> NOMBRE ACTIVIDAD</th>';
                                                                          
       FOR C_DIASEM IN ( 
                                    SELECT 
                                    F.FECHA,
                                    F.DIA NDIA,
                                    CASE WHEN F.NOMBRE_DIA <> 'DOMINGO' AND F.TIPO_DIA = 'DOF' THEN SUBSTR(F.NOMBRE_DIA,1,2)||'(*)' ELSE SUBSTR(F.NOMBRE_DIA,1,2) END DIA
                                     FROM DM_FECHA F
                                    WHERE
                                    F.FECHA BETWEEN TRUNC(SYSDATE-1,'MM') AND TRUNC(SYSDATE-1) +(1-(((1/24)/60))/60) 
                                    ORDER BY
                                    F.FECHA ) 
        LOOP
        
                V_ENCABEZADO := V_ENCABEZADO||'<th align="center">'||C_DIASEM.NDIA||'</th>';
        
        END LOOP;                                                                               
                                                                               
      V_ENCABEZADO := V_ENCABEZADO||'<th align="center">TOTAL</th>';
                                                                          
      V_ENCABEZADO := V_ENCABEZADO||'</tr>
                                                                <tr>';
                                                                
       FOR C_DIASEM IN ( 
                                    SELECT 
                                    F.FECHA,
                                    F.DIA NDIA,
                                    CASE WHEN F.NOMBRE_DIA <> 'DOMINGO' AND F.TIPO_DIA = 'DOF' THEN SUBSTR(F.NOMBRE_DIA,1,2)||'(*)' ELSE SUBSTR(F.NOMBRE_DIA,1,2) END DIA
                                     FROM DM_FECHA F
                                    WHERE
                                    F.FECHA BETWEEN TRUNC(SYSDATE-1,'MM') AND TRUNC(SYSDATE-1) +(1-(((1/24)/60))/60) 
                                    ORDER BY
                                    F.FECHA ) 
        LOOP
        
                V_ENCABEZADO := V_ENCABEZADO||'<th align="center">'||C_DIASEM.DIA||'</th>';
        
        END LOOP;                                                                                            
                                                                
        V_ENCABEZADO := V_ENCABEZADO||'<th>&nbsp;</th>
                                                                </tr>
                                                                      </thead>
                                                                      <tbody>'; 
                                                                      
            V_ENCABEZADO := TRANSLATE(TRANSLATE(V_ENCABEZADO,CHR(10),' '),CHR(13),' ');     
            V_ENCABEZADO := REGEXP_REPLACE(V_ENCABEZADO, '[[:space:]]+',' ' );                     
                    
            DBMS_LOB.WRITE (V_MENSAJE,   LENGTH(V_ENCABEZADO),   1,   V_ENCABEZADO );    /*PRIMERA CADENA DE TEXTO CLOB*/             
            
                                                            
            FOR C_ACTIVIDAD IN (
                                            SELECT 
                                                        A1.ORDEN ID,
                                                        A1.NOMBRE_ACTIVIDAD,
                                                        NVL("1",0) "1", NVL("2",0) "2", NVL("3",0) "3", NVL("4",0) "4", NVL("5",0) "5", NVL("6",0) "6", NVL("7",0) "7", NVL("8",0) "8", NVL("9",0) "9", NVL("10",0) "10", NVL("11",0) "11", NVL("12",0) "12", NVL("13",0) "13", NVL("14",0) "14", NVL("15",0) "15", NVL("16",0) "16", NVL("17",0) "17", NVL("18",0) "18", NVL("19",0) "19", NVL("20",0) "20", NVL("21",0) "21", NVL("22",0) "22", NVL("23",0) "23", NVL("24",0) "24", NVL("25",0) "25", NVL("26",0) "26", NVL("27",0) "27", NVL("28",0) "28", NVL("29",0) "29", NVL("30",0) "30", NVL("31",0) "31",
                                                        NVL(A1."1",0)+NVL(A1."2",0)+NVL(A1."3",0)+NVL(A1."4",0)+NVL(A1."5",0)+NVL(A1."6",0)+NVL(A1."7",0)+NVL(A1."8",0)+NVL(A1."9",0)+NVL(A1."10",0)+NVL(A1."11",0)+NVL(A1."12",0)+NVL(A1."13",0)+NVL(A1."14",0)+NVL(A1."15",0)+NVL(A1."16",0)+NVL(A1."17",0)+NVL(A1."18",0)+NVL(A1."19",0)+NVL(A1."20",0)+NVL(A1."21",0)+NVL(A1."22",0)+NVL(A1."23",0)+NVL(A1."24",0)+NVL(A1."25",0)+NVL(A1."26",0)+NVL(A1."27",0)+NVL(A1."28",0)+NVL(A1."29",0)+NVL(A1."30",0)+NVL(A1."31",0)  TOTAL,
                                                        ROW_NUMBER() OVER(ORDER BY A1.ORDEN) ID_FILA,
                                                        COUNT(*) OVER () TOT_FILAS                                                                         
                                            FROM 
                                                        (
                                                        
                                                        
                                                        /**********************************************************************************************************************************/                                                                
                                                        /*1° PARTE: DE PACIENTES CLINICA HASTA TOTAL IMAGENES*/
                                                        WITH ORDEN_PERSONALIZADO AS 
                                                        (
                                                        SELECT 50002 COD_CENTRO, 'RECUP. POSTOP. (B)' NOMBRE_CCOSTO, 'B' TORRE, 1 ORDEN FROM DUAL UNION ALL
                                                        SELECT 51001 COD_CENTRO, 'URGENCIA (B)' NOMBRE_CCOSTO, 'B' TORRE, 1 ORDEN FROM DUAL UNION ALL
                                                        SELECT 56001 COD_CENTRO, 'GERENCIA GENERAL (B)' NOMBRE_CCOSTO, 'B' TORRE, 1 ORDEN FROM DUAL UNION ALL
                                                        SELECT 58005 COD_CENTRO, 'UPC P11 (B)' NOMBRE_CCOSTO, 'B' TORRE, 1 ORDEN FROM DUAL UNION ALL
                                                        SELECT 58010 COD_CENTRO, 'UCI P11 (B)' NOMBRE_CCOSTO, 'B' TORRE, 1 ORDEN FROM DUAL UNION ALL
                                                        SELECT 58019 COD_CENTRO, 'HABITAC. P9 (B)' NOMBRE_CCOSTO, 'B' TORRE, 1 ORDEN FROM DUAL UNION ALL
                                                        SELECT 50004 COD_CENTRO, 'HABITAC. P8 (A)' NOMBRE_CCOSTO, 'A' TORRE, 2 ORDEN FROM DUAL UNION ALL
                                                        SELECT 50008 COD_CENTRO, 'HABITAC. P12 (A)' NOMBRE_CCOSTO, 'A' TORRE, 2 ORDEN FROM DUAL UNION ALL
                                                        SELECT 50009 COD_CENTRO, 'HABITAC. P13 (A)' NOMBRE_CCOSTO, 'A' TORRE, 2 ORDEN FROM DUAL UNION ALL
                                                        SELECT 50010 COD_CENTRO, 'HABITAC. P14 (A)' NOMBRE_CCOSTO, 'A' TORRE, 2 ORDEN FROM DUAL UNION ALL
                                                        SELECT 50011 COD_CENTRO, 'HABITAC. P11 (A)' NOMBRE_CCOSTO, 'A' TORRE, 2 ORDEN FROM DUAL UNION ALL
                                                        SELECT 50012 COD_CENTRO, 'HABITAC. P15 (A)' NOMBRE_CCOSTO, 'A' TORRE, 2 ORDEN FROM DUAL UNION ALL
                                                        SELECT 58006 COD_CENTRO, 'NEO P7 (A)' NOMBRE_CCOSTO, 'A' TORRE, 2 ORDEN FROM DUAL 
                                                        )

                                                        /*PACIENTES CLINICA y PACIENTES AMBULATORIOS*/                            
                                                       SELECT 
                                                                    P.*
                                                        FROM 
                                                                    (
                                                                    SELECT 
                                                                            DA.ORDEN,
                                                                            DF.DIA,
                                                                            DA.NOMBRE_ACTIVIDAD,
                                                                            SUM(A.TOTAL) TOTAL
                                                                            FROM 
                                                                            FTC_ACTIVIDAD_RESUMEN A,
                                                                            DM_FECHA DF,
                                                                            DM_ACTIVIDADES DA,
                                                                            DM_CENTRO_COSTO CC,
                                                                            DM_ISAPRE DI,
                                                                            DM_PROFESIONAL DP,
                                                                            DM_PRESTACIONES PR
                                                                    WHERE
                                                                            1=1
                                                                            AND A.SID_FECHA = DF.SID_FECHA
                                                                            AND A.SID_ACTIVIDAD = DA.SID_ACTIVIDAD
                                                                            AND A.SID_CENTRO_COSTO = CC.SID_CENTRO_COSTO
                                                                            AND A.SID_ISAPRE = DI.SID_ISAPRE
                                                                            AND A.SID_PRESTACION = PR.SID_PRESTACION
                                                                            AND A.SID_PROF = DP.SID_PROF
                                                                            /*AND DF.FECHA BETWEEN TO_DATE('01/09/2014 00:00:00','DD/MM/YYYY HH24:MI:SS') AND TO_DATE('30/09/2014 23:59:59','DD/MM/YYYY HH24:MI:SS')*/  
                                                                            AND DF.FECHA BETWEEN TRUNC(SYSDATE-1,'MM') AND TRUNC(SYSDATE-1) +(1-(((1/24)/60))/60)
                                                                            AND A.SID_ACTIVIDAD IN (1,2) --NOT IN (11,12,13,14)
                                                                            AND A.ORIGEN = 'REAL'
                                                                    GROUP BY
                                                                    DA.ORDEN,
                                                                            DF.DIA,
                                                                            DA.NOMBRE_ACTIVIDAD
                                                                    ) 
                                                        PIVOT 
                                                                    (  SUM(TOTAL)  FOR DIA IN ( 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31) )  P
                                                                    
                                                                    
                                                        UNION ALL                                                                    
                                                                    
                                                                    
                                                        /*TOTAL DIAS CAMA*/            
                                                       SELECT 
                                                                    P.*
                                                        FROM 
                                                                    (
                                                                    SELECT 
                                                                            DA.ORDEN,
                                                                            DF.DIA,
                                                                            DA.NOMBRE_ACTIVIDAD,
                                                                            SUM(A.TOTAL) TOTAL
                                                                            FROM 
                                                                            FTC_ACTIVIDAD_RESUMEN A,
                                                                            DM_FECHA DF,
                                                                            DM_ACTIVIDADES DA,
                                                                            DM_CENTRO_COSTO CC,
                                                                            DM_ISAPRE DI,
                                                                            DM_PROFESIONAL DP,
                                                                            DM_PRESTACIONES PR
                                                                    WHERE
                                                                            1=1
                                                                            AND A.SID_FECHA = DF.SID_FECHA
                                                                            AND A.SID_ACTIVIDAD = DA.SID_ACTIVIDAD
                                                                            AND A.SID_CENTRO_COSTO = CC.SID_CENTRO_COSTO
                                                                            AND A.SID_ISAPRE = DI.SID_ISAPRE
                                                                            AND A.SID_PRESTACION = PR.SID_PRESTACION
                                                                            AND A.SID_PROF = DP.SID_PROF
                                                                            /*AND DF.FECHA BETWEEN TO_DATE('01/09/2014 00:00:00','DD/MM/YYYY HH24:MI:SS') AND TO_DATE('30/09/2014 23:59:59','DD/MM/YYYY HH24:MI:SS')*/  
                                                                            AND DF.FECHA BETWEEN TRUNC(SYSDATE-1,'MM') AND TRUNC(SYSDATE-1) +(1-(((1/24)/60))/60)
                                                                            AND A.SID_ACTIVIDAD IN (3) --NOT IN (11,12,13,14)
                                                                            AND A.ORIGEN = 'REAL'
                                                                    GROUP BY
                                                                    DA.ORDEN,
                                                                            DF.DIA,
                                                                            DA.NOMBRE_ACTIVIDAD
                                                                    ) 
                                                        PIVOT 
                                                                    (  SUM(TOTAL)  FOR DIA IN ( 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31) )  P             
                                                                    
                                                        
                                                        UNION ALL

                                                        /*APERTURA DIAS CAMA*/        
                                                        SELECT 
                                                                    TO_NUMBER(ORDEN||','||ORDEN_2||FILA) ORDEN,
                                                                    '--- '||INITCAP(R.NOMBRE_CCOSTO) NOMBRE_ACTIVIDAD,
                                                                    "1",	"2",	"3",	"4",	"5",	"6",	"7",	"8",	"9",	"10",	"11",	"12",	"13",	"14",	"15",	"16",	"17",	"18",	"19",	"20",	"21",	"22",	"23",	"24",	"25",	"26",	"27",	"28",	"29",	"30",	"31"
                                                        FROM  
                                                                    (
                                                                    SELECT 
                                                                                Q.*,
                                                                                NVL("1",0)+	NVL("2",0)+	NVL("3",0)+	NVL("4",0)+	NVL("5",0)+	NVL("6",0)+	NVL("7",0)+	NVL("8",0)+	NVL("9",0)+	NVL("10",0)+	NVL("11",0)+	NVL("12",0)+	NVL("13",0)+	NVL("14",0)+	NVL("15",0)+	NVL("16",0)+	NVL("17",0)+	NVL("18",0)+	NVL("19",0)+	NVL("20",0)+	NVL("21",0)+	NVL("22",0)+	NVL("23",0)+	NVL("24",0)+	NVL("25",0)+	NVL("26",0)+	NVL("27",0)+	NVL("28",0)+	NVL("29",0)+	NVL("30",0)+	NVL("31",0) TOTAL,
                                                                                ROW_NUMBER() OVER(PARTITION BY ORDEN, ORDEN_2 ORDER BY NVL("1",0)+	NVL("2",0)+	NVL("3",0)+	NVL("4",0)+	NVL("5",0)+	NVL("6",0)+	NVL("7",0)+	NVL("8",0)+	NVL("9",0)+	NVL("10",0)+	NVL("11",0)+	NVL("12",0)+	NVL("13",0)+	NVL("14",0)+	NVL("15",0)+	NVL("16",0)+	NVL("17",0)+	NVL("18",0)+	NVL("19",0)+	NVL("20",0)+	NVL("21",0)+	NVL("22",0)+	NVL("23",0)+	NVL("24",0)+	NVL("25",0)+	NVL("26",0)+	NVL("27",0)+	NVL("28",0)+	NVL("29",0)+	NVL("30",0)+	NVL("31",0)  DESC )  FILA
                                                                    FROM  
                                                                               (
                                                                               SELECT 
                                                                                            P.*
                                                                                FROM 
                                                                                            (
                                                                                            SELECT 
                                                                                                    DA.ORDEN,
                                                                                                    OP.ORDEN ORDEN_2,
                                                                                                    DF.DIA,
                                                                                                    DA.NOMBRE_ACTIVIDAD,
                                                                                                    OP.COD_CENTRO,
                                                                                                    OP.NOMBRE_CCOSTO,
                                                                                                    SUM(A.TOTAL) TOTAL
                                                                                                    FROM 
                                                                                                    FTC_ACTIVIDAD_RESUMEN A,
                                                                                                    DM_FECHA DF,
                                                                                                    DM_ACTIVIDADES DA,
                                                                                                    DM_CENTRO_COSTO CC,
                                                                                                    DM_ISAPRE DI,
                                                                                                    DM_PROFESIONAL DP,
                                                                                                    DM_PRESTACIONES PR,
                                                                                                    ORDEN_PERSONALIZADO OP
                                                                                            WHERE
                                                                                                    1=1
                                                                                                    AND A.SID_FECHA = DF.SID_FECHA
                                                                                                    AND A.SID_ACTIVIDAD = DA.SID_ACTIVIDAD
                                                                                                    AND A.SID_CENTRO_COSTO = CC.SID_CENTRO_COSTO
                                                                                                    AND A.SID_ISAPRE = DI.SID_ISAPRE
                                                                                                    AND A.SID_PRESTACION = PR.SID_PRESTACION
                                                                                                    AND A.SID_PROF = DP.SID_PROF
                                                                                                    AND CC.COD_CENTRO = OP.COD_CENTRO(+)
                                                                                                    /*AND DF.FECHA BETWEEN TO_DATE('01/09/2014 00:00:00','DD/MM/YYYY HH24:MI:SS') AND TO_DATE('30/09/2014 23:59:59','DD/MM/YYYY HH24:MI:SS')*/  
                                                                                                    AND DF.FECHA BETWEEN TRUNC(SYSDATE-1,'MM') AND TRUNC(SYSDATE-1) +(1-(((1/24)/60))/60)
                                                                                                    AND A.SID_ACTIVIDAD IN (3) --NOT IN (11,12,13,14)
                                                                                                    AND A.ORIGEN = 'REAL'
                                                                                            GROUP BY
                                                                                            DA.ORDEN,
                                                                                                    DF.DIA,
                                                                                                    DA.NOMBRE_ACTIVIDAD,
                                                                                                    OP.COD_CENTRO,
                                                                                                    OP.NOMBRE_CCOSTO,
                                                                                                    OP.ORDEN 
                                                                                            ) 
                                                                                PIVOT 
                                                                                            (  SUM(TOTAL)  FOR DIA IN ( 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31) )  P                
                                                                                
                                                                                            ) Q
                                                                                ) R

                                                        UNION ALL
                                                                    
                                                        /*EL RESTO*/            
                                                       SELECT 
                                                                    P.*
                                                        FROM 
                                                                    (
                                                                    SELECT 
                                                                            DA.ORDEN,
                                                                            DF.DIA,
                                                                            DA.NOMBRE_ACTIVIDAD,
                                                                            SUM(A.TOTAL) TOTAL
                                                                            FROM 
                                                                            FTC_ACTIVIDAD_RESUMEN A,
                                                                            DM_FECHA DF,
                                                                            DM_ACTIVIDADES DA,
                                                                            DM_CENTRO_COSTO CC,
                                                                            DM_ISAPRE DI,
                                                                            DM_PROFESIONAL DP,
                                                                            DM_PRESTACIONES PR
                                                                    WHERE
                                                                            1=1
                                                                            AND A.SID_FECHA = DF.SID_FECHA
                                                                            AND A.SID_ACTIVIDAD = DA.SID_ACTIVIDAD
                                                                            AND A.SID_CENTRO_COSTO = CC.SID_CENTRO_COSTO
                                                                            AND A.SID_ISAPRE = DI.SID_ISAPRE
                                                                            AND A.SID_PRESTACION = PR.SID_PRESTACION
                                                                            AND A.SID_PROF = DP.SID_PROF
                                                                            /*AND DF.FECHA BETWEEN TO_DATE('01/09/2014 00:00:00','DD/MM/YYYY HH24:MI:SS') AND TO_DATE('30/09/2014 23:59:59','DD/MM/YYYY HH24:MI:SS')*/  
                                                                            AND DF.FECHA BETWEEN TRUNC(SYSDATE-1,'MM') AND TRUNC(SYSDATE-1) +(1-(((1/24)/60))/60)
                                                                            AND A.SID_ACTIVIDAD IN (
                                                                                                                         4 /*PABELLONES*/
                                                                                                                        ,5 /*PARTOS Y CESAREAS*/
                                                                                                                        ,6 /*CIRUGIAS*/
                                                                                                                        ,7 /*CONSULTAS MEDICAS*/
                                                                                                                        ,8 /*CONSULTAS DENTALES*/
                                                                                                                        ,9 /*CONSULTAS DE URGENCIA*/
                                                                                                                        ,10 /*IMAGENES*/
                                                                                                                        ,15 /*PACIENTES NO ATENDIDOS URGENCIA*/
                                                                            )
                                                                            AND A.ORIGEN = 'REAL'
                                                                    GROUP BY
                                                                    DA.ORDEN,
                                                                            DF.DIA,
                                                                            DA.NOMBRE_ACTIVIDAD
                                                                    ) 
                                                        PIVOT 
                                                                    (  SUM(TOTAL)  FOR DIA IN ( 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31) )  P 
                                                                    
                                            /**********************************************************************************************************************************/                                                                
                                                                    
                                             /*2° PARTE: DESDE DETALLE DE IMAGENES HASTA DETALLE DE PROCEDIMIENTOS*/                               
                                            UNION ALL

                                                        SELECT 
                                                                    P.*
                                                        FROM 
                                                                    (
                                                                    SELECT 
                                                                            DA.ORDEN,
                                                                            DF.DIA,
                                                                            '---'||CC.NOMBRE_CCOSTO,
                                                                            SUM(A.TOTAL) TOTAL
                                                                            FROM 
                                                                            FTC_ACTIVIDAD_RESUMEN A,
                                                                            DM_FECHA DF,
                                                                            DM_ACTIVIDADES DA,
                                                                            DM_CENTRO_COSTO CC,
                                                                            DM_ISAPRE DI,
                                                                            DM_PROFESIONAL DP,
                                                                            DM_PRESTACIONES PR
                                                                    WHERE
                                                                            1=1
                                                                            AND A.SID_FECHA = DF.SID_FECHA
                                                                            AND A.SID_ACTIVIDAD = DA.SID_ACTIVIDAD
                                                                            AND A.SID_CENTRO_COSTO = CC.SID_CENTRO_COSTO
                                                                            AND A.SID_ISAPRE = DI.SID_ISAPRE
                                                                            AND A.SID_PRESTACION = PR.SID_PRESTACION
                                                                            AND A.SID_PROF = DP.SID_PROF
                                                                            /*AND DF.FECHA BETWEEN TO_DATE('01/09/2014 00:00:00','DD/MM/YYYY HH24:MI:SS') AND TO_DATE('30/09/2014 23:59:59','DD/MM/YYYY HH24:MI:SS')*/  
                                                                            AND DF.FECHA BETWEEN TRUNC(SYSDATE-1,'MM') AND TRUNC(SYSDATE-1) +(1-(((1/24)/60))/60)
                                                                            AND A.SID_ACTIVIDAD = 10 
                                                                            AND A.ORIGEN = 'REAL'
                                                                    GROUP BY
                                                                    DA.ORDEN,
                                                                            DF.DIA,
                                                                            CC.NOMBRE_CCOSTO
                                                                    ) 
                                                        PIVOT 
                                                                    (  SUM(TOTAL)  FOR DIA IN ( 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31) )  P                   
                                                                               

                                            UNION ALL

                                                        SELECT 
                                                                    P.*
                                                        FROM 
                                                                    (
                                                                    SELECT 
                                                                            12 ORDEN,
                                                                            DF.DIA,
                                                                            DA.NOMBRE_ACTIVIDAD,
                                                                            SUM(A.TOTAL) TOTAL
                                                                            FROM 
                                                                            FTC_ACTIVIDAD_RESUMEN A,
                                                                            DM_FECHA DF,
                                                                            DM_ACTIVIDADES DA,
                                                                            DM_CENTRO_COSTO CC,
                                                                            DM_ISAPRE DI,
                                                                            DM_PROFESIONAL DP,
                                                                            DM_PRESTACIONES PR
                                                                    WHERE
                                                                            1=1
                                                                            AND A.SID_FECHA = DF.SID_FECHA
                                                                            AND A.SID_ACTIVIDAD = DA.SID_ACTIVIDAD
                                                                            AND A.SID_CENTRO_COSTO = CC.SID_CENTRO_COSTO
                                                                            AND A.SID_ISAPRE = DI.SID_ISAPRE
                                                                            AND A.SID_PRESTACION = PR.SID_PRESTACION
                                                                            AND A.SID_PROF = DP.SID_PROF
                                                                            /*AND DF.FECHA BETWEEN TO_DATE('01/09/2014 00:00:00','DD/MM/YYYY HH24:MI:SS') AND TO_DATE('30/09/2014 23:59:59','DD/MM/YYYY HH24:MI:SS')*/  
                                                                            AND DF.FECHA BETWEEN TRUNC(SYSDATE-1,'MM') AND TRUNC(SYSDATE-1) +(1-(((1/24)/60))/60)
                                                                            AND A.SID_ACTIVIDAD  IN (11,12,13)
                                                                            AND A.ORIGEN = 'REAL'
                                                                    GROUP BY
                                                                            DF.DIA,
                                                                            DA.NOMBRE_ACTIVIDAD
                                                                    ) 
                                                        PIVOT 
                                                                    (  SUM(TOTAL)  FOR DIA IN ( 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31) )  P                        
                                                                            
                                            UNION ALL

                                                      /*CARDIOLOGIA*/ 
                                                       SELECT 
                                                                    P.*
                                                        FROM 
                                                                    (
                                                                    SELECT 
                                                                            12 ORDEN,
                                                                            DF.DIA,
                                                                            '---CARDIOLOGIA',
                                                                            SUM(A.TOTAL) TOTAL
                                                                            FROM 
                                                                            FTC_ACTIVIDAD_RESUMEN A,
                                                                            DM_FECHA DF,
                                                                            DM_ACTIVIDADES DA,
                                                                            DM_CENTRO_COSTO CC,
                                                                            DM_ISAPRE DI,
                                                                            DM_PROFESIONAL DP,
                                                                            DM_PRESTACIONES PR
                                                                    WHERE
                                                                            1=1
                                                                            AND A.SID_FECHA = DF.SID_FECHA
                                                                            AND A.SID_ACTIVIDAD = DA.SID_ACTIVIDAD
                                                                            AND A.SID_CENTRO_COSTO = CC.SID_CENTRO_COSTO
                                                                            AND A.SID_ISAPRE = DI.SID_ISAPRE
                                                                            AND A.SID_PRESTACION = PR.SID_PRESTACION
                                                                            AND A.SID_PROF = DP.SID_PROF
                                                                            /*AND DF.FECHA BETWEEN TO_DATE('01/09/2014 00:00:00','DD/MM/YYYY HH24:MI:SS') AND TO_DATE('30/09/2014 23:59:59','DD/MM/YYYY HH24:MI:SS')*/  
                                                                            AND DF.FECHA BETWEEN TRUNC(SYSDATE-1,'MM') AND TRUNC(SYSDATE-1) +(1-(((1/24)/60))/60)
                                                                            AND A.SID_ACTIVIDAD  = 11
                                                                            AND A.ORIGEN = 'REAL'
                                                                    GROUP BY
                                                                            DF.DIA,
                                                                            DA.NOMBRE_ACTIVIDAD_N2
                                                                    ) 
                                                        PIVOT 
                                                                    (  SUM(TOTAL)  FOR DIA IN ( 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31) )  P                                   
                                                                            
                                            UNION ALL

                                                        /*NEUROLOGIA*/
                                                        SELECT 
                                                                    P.*
                                                        FROM 
                                                                    (
                                                                    SELECT 
                                                                            12.2 ORDEN,
                                                                            DF.DIA,
                                                                            '---NEUROLOGIA',
                                                                            SUM(A.TOTAL) TOTAL
                                                                            FROM 
                                                                            FTC_ACTIVIDAD_RESUMEN A,
                                                                            DM_FECHA DF,
                                                                            DM_ACTIVIDADES DA,
                                                                            DM_CENTRO_COSTO CC,
                                                                            DM_ISAPRE DI,
                                                                            DM_PROFESIONAL DP,
                                                                            DM_PRESTACIONES PR
                                                                    WHERE
                                                                            1=1
                                                                            AND A.SID_FECHA = DF.SID_FECHA
                                                                            AND A.SID_ACTIVIDAD = DA.SID_ACTIVIDAD
                                                                            AND A.SID_CENTRO_COSTO = CC.SID_CENTRO_COSTO
                                                                            AND A.SID_ISAPRE = DI.SID_ISAPRE
                                                                            AND A.SID_PRESTACION = PR.SID_PRESTACION
                                                                            AND A.SID_PROF = DP.SID_PROF
                                                                            /*AND DF.FECHA BETWEEN TO_DATE('01/09/2014 00:00:00','DD/MM/YYYY HH24:MI:SS') AND TO_DATE('30/09/2014 23:59:59','DD/MM/YYYY HH24:MI:SS')*/  
                                                                            AND DF.FECHA BETWEEN TRUNC(SYSDATE-1,'MM') AND TRUNC(SYSDATE-1) +(1-(((1/24)/60))/60)
                                                                            AND A.SID_ACTIVIDAD  = 12
                                                                            AND A.ORIGEN = 'REAL'
                                                                    GROUP BY
                                                                            DF.DIA,
                                                                            DA.NOMBRE_ACTIVIDAD_N2
                                                                    ) 
                                                        PIVOT 
                                                                    (  SUM(TOTAL)  FOR DIA IN ( 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31) )  P                                   
                                                                            
                                            UNION ALL

                                                        SELECT 
                                                                    P.*
                                                        FROM 
                                                                    (
                                                                    SELECT 
                                                                            12.4 ORDEN,
                                                                            DF.DIA,
                                                                            '---OTORRINO',
                                                                            SUM(A.TOTAL) TOTAL
                                                                            FROM 
                                                                            FTC_ACTIVIDAD_RESUMEN A,
                                                                            DM_FECHA DF,
                                                                            DM_ACTIVIDADES DA,
                                                                            DM_CENTRO_COSTO CC,
                                                                            DM_ISAPRE DI,
                                                                            DM_PROFESIONAL DP,
                                                                            DM_PRESTACIONES PR
                                                                    WHERE
                                                                            1=1
                                                                            AND A.SID_FECHA = DF.SID_FECHA
                                                                            AND A.SID_ACTIVIDAD = DA.SID_ACTIVIDAD
                                                                            AND A.SID_CENTRO_COSTO = CC.SID_CENTRO_COSTO
                                                                            AND A.SID_ISAPRE = DI.SID_ISAPRE
                                                                            AND A.SID_PRESTACION = PR.SID_PRESTACION
                                                                            AND A.SID_PROF = DP.SID_PROF
                                                                            /*AND DF.FECHA BETWEEN TO_DATE('01/09/2014 00:00:00','DD/MM/YYYY HH24:MI:SS') AND TO_DATE('30/09/2014 23:59:59','DD/MM/YYYY HH24:MI:SS')*/  
                                                                            AND DF.FECHA BETWEEN TRUNC(SYSDATE-1,'MM') AND TRUNC(SYSDATE-1) +(1-(((1/24)/60))/60)
                                                                            AND CC.COD_CENTRO IN (53005,53018)
                                                                            AND A.ORIGEN = 'REAL'
                                                                    GROUP BY
                                                                            DF.DIA
                                                                    ) 
                                                        PIVOT 
                                                                    (  SUM(TOTAL)  FOR DIA IN ( 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31) )  P                                                         
                                                     
                                            UNION ALL


                                                       SELECT 
                                                                    P.*
                                                        FROM 
                                                                    (
                                                                    SELECT 
                                                                            12.5 ORDEN,
                                                                            DF.DIA,
                                                                            '---RESPIRATORIO',
                                                                            SUM(A.TOTAL) TOTAL
                                                                            FROM 
                                                                            FTC_ACTIVIDAD_RESUMEN A,
                                                                            DM_FECHA DF,
                                                                            DM_ACTIVIDADES DA,
                                                                            DM_CENTRO_COSTO CC,
                                                                            DM_ISAPRE DI,
                                                                            DM_PROFESIONAL DP,
                                                                            DM_PRESTACIONES PR
                                                                    WHERE
                                                                            1=1
                                                                            AND A.SID_FECHA = DF.SID_FECHA
                                                                            AND A.SID_ACTIVIDAD = DA.SID_ACTIVIDAD
                                                                            AND A.SID_CENTRO_COSTO = CC.SID_CENTRO_COSTO
                                                                            AND A.SID_ISAPRE = DI.SID_ISAPRE
                                                                            AND A.SID_PRESTACION = PR.SID_PRESTACION
                                                                            AND A.SID_PROF = DP.SID_PROF
                                                                            /*AND DF.FECHA BETWEEN TO_DATE('01/09/2014 00:00:00','DD/MM/YYYY HH24:MI:SS') AND TO_DATE('30/09/2014 23:59:59','DD/MM/YYYY HH24:MI:SS')*/  
                                                                            AND DF.FECHA BETWEEN TRUNC(SYSDATE-1,'MM') AND TRUNC(SYSDATE-1) +(1-(((1/24)/60))/60)
                                                                            AND CC.COD_CENTRO IN (53004)
                                                                            AND A.ORIGEN = 'REAL'
                                                                    GROUP BY
                                                                            DF.DIA
                                                                    ) 
                                                        PIVOT 
                                                                    (  SUM(TOTAL)  FOR DIA IN ( 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31) )  P           

                                            UNION ALL                        

                                                        SELECT 
                                                                    P.*
                                                        FROM 
                                                                    (
                                                                    SELECT 
                                                                            12.6 ORDEN,
                                                                            DF.DIA,
                                                                            '---GASTROENTEROLOGIA',
                                                                            SUM(A.TOTAL) TOTAL
                                                                            FROM 
                                                                            FTC_ACTIVIDAD_RESUMEN A,
                                                                            DM_FECHA DF,
                                                                            DM_ACTIVIDADES DA,
                                                                            DM_CENTRO_COSTO CC,
                                                                            DM_ISAPRE DI,
                                                                            DM_PROFESIONAL DP,
                                                                            DM_PRESTACIONES PR
                                                                    WHERE
                                                                            1=1
                                                                            AND A.SID_FECHA = DF.SID_FECHA
                                                                            AND A.SID_ACTIVIDAD = DA.SID_ACTIVIDAD
                                                                            AND A.SID_CENTRO_COSTO = CC.SID_CENTRO_COSTO
                                                                            AND A.SID_ISAPRE = DI.SID_ISAPRE
                                                                            AND A.SID_PRESTACION = PR.SID_PRESTACION
                                                                            AND A.SID_PROF = DP.SID_PROF
                                                                            /*AND DF.FECHA BETWEEN TO_DATE('01/09/2014 00:00:00','DD/MM/YYYY HH24:MI:SS') AND TO_DATE('30/09/2014 23:59:59','DD/MM/YYYY HH24:MI:SS')*/  
                                                                            AND DF.FECHA BETWEEN TRUNC(SYSDATE-1,'MM') AND TRUNC(SYSDATE-1) +(1-(((1/24)/60))/60)
                                                                            AND CC.COD_CENTRO IN (53002)
                                                                            AND A.ORIGEN = 'REAL'
                                                                   GROUP BY
                                                                            DF.DIA
                                                                    ) 
                                                        PIVOT 
                                                                    (  SUM(TOTAL)  FOR DIA IN ( 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31) )  P           

                                                                                                                            
                                                        ) A1
                                                                
                                                ORDER BY 1, 3 DESC
                                             )        
            LOOP
                                V_CUERPO := (V_CUERPO||' '||
                                                         '<tr class="'||CASE WHEN MOD(C_ACTIVIDAD.ID_FILA,2) = 0 THEN  'alt' ELSE NULL END||' ">'
                                                        || CASE WHEN C_ACTIVIDAD.NOMBRE_ACTIVIDAD = 'PACIENTES NO ATENDIDOS URGENCIA' THEN  
                                                                            '<td style ="color:red">'||C_ACTIVIDAD.NOMBRE_ACTIVIDAD ||'</td>' 
                                                                      ELSE
                                                                             '<td>'||C_ACTIVIDAD.NOMBRE_ACTIVIDAD ||'</td>'
                                                            END             
                                                       );
                                     
                                IF C_ACTIVIDAD.NOMBRE_ACTIVIDAD = 'PACIENTES NO ATENDIDOS URGENCIA' THEN         
      
                                                        IF V_NDIA >= 1 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."1", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 2 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."2", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 3 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."3", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 4 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."4", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 5 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."5", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 6 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."6", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 7 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."7", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 8 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."8", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 9 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."9", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 10 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."10", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 11 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."11", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 12 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."12", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 13 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."13", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 14 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."14", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 15 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."15", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 16 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."16", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 17 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."17", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 18 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."18", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 19 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."19", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 20 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."20", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 21 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."21", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 22 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."22", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 23 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."23", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 24 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."24", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 25 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."25", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 26 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."26", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 27 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."27", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 28 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."28", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 29 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."29", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 30 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."30", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 31 THEN V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD."31", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        
                                                        V_CUERPO := V_CUERPO||'<td align="right" style ="color:red">'||REPLACE(TO_CHAR(C_ACTIVIDAD.TOTAL, '999,999,999,999'),',','.')||'</td>';           
                                                        V_CUERPO := TRANSLATE(TRANSLATE(TRANSLATE(V_CUERPO,CHR(10),' '),CHR(13),' '),CHR(9),' ')  ;                                                       
                                            
                                          ELSE
                                          
                                                        IF V_NDIA >= 1 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."1", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 2 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."2", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 3 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."3", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 4 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."4", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 5 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."5", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 6 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."6", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 7 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."7", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 8 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."8", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 9 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."9", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 10 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."10", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 11 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."11", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 12 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."12", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 13 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."13", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 14 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."14", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 15 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."15", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 16 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."16", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 17 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."17", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 18 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."18", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 19 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."19", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 20 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."20", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 21 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."21", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 22 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."22", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 23 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."23", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 24 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."24", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 25 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."25", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 26 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."26", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 27 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."27", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 28 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."28", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 29 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."29", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 30 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."30", '999,999,999,999'),',','.')||'</td>'; END IF;
                                                        IF V_NDIA >= 31 THEN V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD."31", '999,999,999,999'),',','.')||'</td>'; END IF;        
                                                        
                                                        V_CUERPO := V_CUERPO||'<td align="right">'||REPLACE(TO_CHAR(C_ACTIVIDAD.TOTAL, '999,999,999,999'),',','.')||'</td>';           
                                                                                                                                       
                                          
                                          
                                          END IF;  
                                            
                                            
                                            

                                
                                V_CUERPO := V_CUERPO|| '</tr>';
                                V_CUERPO := REGEXP_REPLACE(V_CUERPO, '[[:space:]]+',' ' );                                        
                                V_CUERPO := TRANSLATE(TRANSLATE(TRANSLATE(V_CUERPO,CHR(10),' '),CHR(13),' '),CHR(9),' ')  ;      
                                DBMS_LOB.WRITE (V_MENSAJE,  LENGTH(V_CUERPO),  DBMS_LOB.GETLENGTH (V_MENSAJE) + 1,   V_CUERPO );         
                                V_CUERPO := NULL;                           
            END LOOP;
                    
            V_CUERPO := ' ';
                    
            V_CUERPO := V_CUERPO||'<tr>';
            V_CUERPO := V_CUERPO||'<th align="center" class="diasAbajo">&nbsp;</th>';
           
            
              FOR C_DIASEM IN ( 
                                            SELECT 
                                            F.FECHA,
                                            F.DIA NDIA,
                                            CASE WHEN F.NOMBRE_DIA <> 'DOMINGO' AND F.TIPO_DIA = 'DOF' THEN SUBSTR(F.NOMBRE_DIA,1,2)||'(*)' ELSE SUBSTR(F.NOMBRE_DIA,1,2) END DIA
                                             FROM DM_FECHA F
                                            WHERE
                                            F.FECHA BETWEEN TRUNC(SYSDATE-1,'MM') AND TRUNC(SYSDATE-1) +(1-(((1/24)/60))/60) 
                                            ORDER BY
                                            F.FECHA ) 
                LOOP
                
                        V_CUERPO := V_CUERPO||'<th align="center" class="diasAbajo">'||TO_CHAR(C_DIASEM.DIA)||'</th>';
                
                END LOOP;                           

            V_CUERPO := V_CUERPO||'<th align="center" class="diasAbajo">&nbsp;</th>';            
            V_CUERPO := V_CUERPO||'</tr>';                          
                    
            V_CUERPO := V_CUERPO||'<tr>';
            V_CUERPO := V_CUERPO||'<th align="center" class="diasAbajo">&nbsp;</th>';

           FOR C_DIASEM IN ( 
                                        SELECT 
                                        F.FECHA,
                                        F.DIA NDIA,
                                        CASE WHEN F.NOMBRE_DIA <> 'DOMINGO' AND F.TIPO_DIA = 'DOF' THEN SUBSTR(F.NOMBRE_DIA,1,2)||'(*)' ELSE SUBSTR(F.NOMBRE_DIA,1,2) END DIA
                                         FROM DM_FECHA F
                                        WHERE
                                        F.FECHA BETWEEN TRUNC(SYSDATE-1,'MM') AND TRUNC(SYSDATE-1) +(1-(((1/24)/60))/60) 
                                        ORDER BY
                                        F.FECHA ) 
            LOOP
            
                    V_CUERPO := V_CUERPO||'<th align="center"  class="diasAbajo">'||TO_CHAR(C_DIASEM.NDIA)||'</th>';
            
            END LOOP;                                                          
                                                                                
            V_CUERPO := V_CUERPO||'<th align="center" class="diasAbajo">Total</th>';            
            V_CUERPO := V_CUERPO||'</tr>';         

            V_CUERPO := TRANSLATE(TRANSLATE(V_CUERPO,CHR(10),' '),CHR(13),' ');                                 
            V_CUERPO := REGEXP_REPLACE(V_CUERPO, '[[:space:]]+',' ' );             
--            DBMS_OUTPUT.PUT_LINE('V_CUERPO:  '|| V_CUERPO); 
            DBMS_LOB.WRITE (V_MENSAJE,  LENGTH(V_CUERPO),  DBMS_LOB.GETLENGTH (V_MENSAJE) + 1,   V_CUERPO );                   
             
            V_PIE:=  '</tbody></table></div>
                                <p align="center"><img src="http://www.clinicavespucio.cl/wp-content/themes/clinica_vespucio/images/logo_clinica_vespucio.svg" alt="logo clinica" />
                                <br><br><br>
                            </body></html>' ;         
                            
            V_PIE := TRANSLATE(TRANSLATE(V_PIE,CHR(10),' '),CHR(13),' ');                                 
            V_PIE := REGEXP_REPLACE(V_PIE, '[[:space:]]+',' ' );           
            DBMS_LOB.WRITE (V_MENSAJE,  LENGTH(V_PIE),  DBMS_LOB.GETLENGTH (V_MENSAJE) + 1,   V_PIE );     
            
            --DBMS_OUTPUT.PUT_LINE('V_MENSAJE:  '|| V_MENSAJE); 
            
                                                
            GENERALES.P_ENVIAR_EMAIL_CLOB  ( 
                                                                            p_to          =>  
                                                                                                'jsabaj@clinicavespucio.cl;'
                                                                                                ||'casenjo@clinicavespucio.cl;'
                                                                                                ||'smella@clinicavespucio.cl;'
                                                                                                ||'vsilveira@clinicavespucio.cl;'
                                                                                                ||'mcarvacho@clinicavespucio.cl;'
                                                                                                ||'ainnocenti@clinicavespucio.cl;'
                                                                                                ||'rastudillo@clinicavespucio.cl;'
                                                                                                ||'cmonardes@clinicavespucio.cl;'
                                                                                                ||'hlahsen@clinicavespucio.cl;'
                                                                                                ||'cmorales@clinicavespucio.cl;'
                                                                                                ||'ecarrizo@clinicavespucio.cl;'
                                                                                                ||'futili@clinicavespucio.cl;'
                                                                                                ||'jyanez@clinicavespucio.cl;'
                                                                                                ||'lnorambuena@clinicavespucio.cl;'
                                                                                                ||'mcorral@clinicavespucio.cl;'
                                                                                                ||'mvidal@clinicavespucio.cl;'
                                                                                                ||'ptorres@clinicavespucio.cl;'
                                                                                                ||'rrivera@clinicavespucio.cl;'
                                                                                                ||'vjara@clinicavespucio.cl;'
                                                                                                ||'caguilerav@clinicavespucio.cl;'
                                                                                                ||'cloyola@clinicavespucio.cl;'
                                                                                                ||'lortega@clinicavespucio.cl;'
                                                                                                ||'cgarcia@clinicavespucio.cl;'
                                                                                                ||'alvaro.figueroa@clinicavespucio.cl;'                                                                                                
                                                                                                ||'diego.palma@clinicavespucio.cl;'      
                                                                                                ||'jtevah@clinicavespucio.cl;'
                                                                                                ||'fhernandezg@clinicavespucio.cl;'                           
                                                                                                /**/                                                                          
                                                                                                ||'pcurinao@clinicavespucio.cl',                                                                                                  
--                                                                            p_to             => 'juansabajmanzur@gmail.com;pcurinao@clinicavespucio.cl;pcurinao@gmail.com;edison.carrizo.j@gmail.com;ecarrizo@clinicavespucio.cl;smella@fen.uchile.cl;smella@clinicavespucio.cl',                                                                     
--                                                                            p_to            =>  'diego.palma@clinicavespucio.cl',
--                                                                            p_to =>  'pcurinao@clinicavespucio.cl;pcurinao@gmail.com',
--                                                                            p_to             => 'pcurinao@clinicavespucio.cl;smella@clinicavespucio.cl;jsabaj@clinicavespucio.cl',
--                                                                            p_to             => 'pcurinao@gmail.com;edison.carrizo.j@gmail.com;ecarrizo@clinicavespucio.cl',
--                                                                            p_to             => 'pcurinao@clinicavespucio.cl',
                                                                            p_from => 'servidor.gestion@clinicavespucio.cl',
                                                                            p_subject  => 'Resumen Actividad Diaria al '||TO_CHAR(SYSDATE-1,'DD')||'-'||SUBSTR(TRIM(INITCAP(TO_CHAR(SYSDATE-1,'MONTH'))),1,3)||'-'|| TO_CHAR(SYSDATE-1,'YYYY')||'   (mobile)' ,
                                                                            p_msg => V_MENSAJE,
                                                                            p_alias => 'Actividad'
                                                                            );

END P_ENVIAR_MAIL_ACTIVIDAD_DIARIA;
/
SHOW ERRORS


--EXECUTE P_ENVIAR_MAIL_ACTIVIDAD_DIARIA;