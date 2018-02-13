set define off;
CREATE OR REPLACE PROCEDURE DW.P_ENVIAR_MAIL_VENTA_DIARIA AS
/*V5: 21/11/2014: Se agrega venta proyectada hasta fin de mes
   V7: 06-02-2015: Se agreaga ultima linea con el ppto obtenido de tabla temporal TMP_PPTO_2015. Solicitud de SMELLA.
   V8: 19-02-2015: Se agrega Venta OMESA bajo el subtotal a solicitud de JSABAJ.
                              Se crea variables V_FECHA_PROCESO y V_FECHA_ACTUAL_SISTEMA para poder hacer pruebas cambiamdo la fecha.
    V8.1: 08-03-2015: Se hacen correcciones con respecto a como se muestran totales y subtotales     
    v9:    17-11-2015: Se deja de mostrar 20 millones como margen OMESA. Desde ahora la proyección de este dato se saca del promedio de los últimos 6 meses que vienen de la Contabilidad (cuenta: 4111160086). A mes vencido se muestra dato real contable.   
    v9.1: 01-12-2015: Se saca Venta Omesa, ya que se duplica el último día del mes.           
    v9.2: 12-05-2017: Se agrega ESCENARIO a tabla PPTO_VENTA_MONITOR              
*/


V_ENCABEZADO VARCHAR2(32767);
V_CUERPO VARCHAR2(32767);
V_PIE VARCHAR2(32767);

V_SUBTOT_HOSP NUMBER := 0;
V_SUBTOT_AMB    NUMBER := 0;
V_SUBTOT_TOTAL NUMBER := 0;

V_TOT_HOSP NUMBER := 0;
V_TOT_AMB    NUMBER := 0;
V_TOT_TOTAL NUMBER := 0;

V_TOT_PPTO_VTA_HOSP NUMBER := 0;
V_TOT_PPTO_VTA_AMB NUMBER := 0;
V_TOT_PPTO_VENTA NUMBER := 0;

V_ES_DIA_PAR BOOLEAN := TRUE; 
--V_FECHA_PROCESO DATE :=  TO_DATE('28/02/2015 00:00:00','DD/MM/YYYY HH24:MI:SS');
V_FECHA_PROCESO DATE := SYSDATE-1;  /*POR DEFECTO DEBE SER SIEMPRE SYSDATE-1. CAMBIAR SOLO PARA HACER PRUEBAS*/
V_FECHA_ACTUAL_SISTEMA DATE := V_FECHA_PROCESO + 1;

V_TOT_VENTA_OMESA NUMBER := 20000000; 

V_MENSAJE CLOB := ' '; 


BEGIN

            /*17-11-2015: SE OBTIENE MARGEN OMESA*/
            SELECT 
                        SUM(FT.NETO) VENTA_NETA
                        INTO V_TOT_VENTA_OMESA
            FROM 
                        FTC_VENTA_RESUMEN FT,
                        DM_FECHA F,
                        DM_ORIGEN_VENTA OV,
                        DM_CENTRO_COSTO CC
            WHERE
                        1=1
                        AND FT.SID_FECHA = F.SID_FECHA
                        AND FT.SID_ORIGEN_VENTA = OV.SID_ORIGEN_VENTA
                        AND FT.SID_CENTRO_COSTO = CC.SID_CENTRO_COSTO
                        AND F.FECHA BETWEEN TRUNC(SYSDATE-1,'MM') AND LAST_DAY(TRUNC(SYSDATE-1))+(1-(((1/24)/60))/60)      
                        AND FT.TIPO_VENTA = 'AMB'
                        AND CC.COD_CENTRO = 54009 /* LABORATORIO VIDAINTEGRA */ ;           


            /*CARGA TEMPORALMENTE PPTO DE VENTA*/
            BEGIN
            SELECT PP.PPTO_VENTA_HOSP INTO V_TOT_PPTO_VTA_HOSP FROM PPTO_VENTA_MONITOR PP WHERE PP.FECHA_PPTO = TRUNC(V_FECHA_PROCESO,'MM') AND PP.ESCENARIO = 1 ;
            SELECT PP.PPTO_VENTA_AMB  INTO V_TOT_PPTO_VTA_AMB FROM PPTO_VENTA_MONITOR PP WHERE PP.FECHA_PPTO = TRUNC(V_FECHA_PROCESO,'MM') AND PP.ESCENARIO = 1 ;
            
            EXCEPTION WHEN OTHERS THEN NULL;
            END;
            
            V_TOT_PPTO_VENTA := V_TOT_PPTO_VTA_HOSP + V_TOT_PPTO_VTA_AMB;


            V_ENCABEZADO := '<!DOCTYPE HTML>
                                                                <html>
                                                                    <head>
                                                                        <style type="text/css">
                                                                        .datagrid table {
                                                                            border-collapse: collapse;
                                                                            text-align: left;
                                                                            width: 100%;
                                                                        }
                                                                        .datagrid {
                                                                            font: normal 12px/150% Verdana, Helvetica, Arial sans-serif;
                                                                            background: #fff;
                                                                            overflow: hidden;
                                                                            border: 1px solid #006699;
                                                                            -webkit-border-radius: 3px;
                                                                            -moz-border-radius: 3px;
                                                                            border-radius: 3px;
                                                                            /*width: 50%;*/
                                                                        }
                                                                        .datagrid table td, .datagrid table th {
                                                                            padding: 3px 10px;
                                                                        }
                                                                        .datagrid table thead th {
                                                                            background: -webkit-gradient( linear, left top, left bottom, color-stop(0.05, #006699), color-stop(1, #00557F) );
                                                                            background: -moz-linear-gradient( center top, #006699 5%, #00557F 200px );
                                                                        filter:progid:DXImageTransform.Microsoft.gradient(startColorstr="#006699", endColorstr="#00557F");
                                                                            background-color: #006699;
                                                                            color: #FFFFFF;
                                                                            font-size: 15px;
                                                                            font-weight: bold;
                                                                            border-left: 1px solid #0070A8;
                                                                        }
                                                                        .datagrid table thead th:first-child {
                                                                            border: none;
                                                                        }
                                                                        .datagrid table tbody td {
                                                                            color: #00557F;
                                                                            border-left: 1px solid #E1EEF4;
                                                                            font-size: 15px;
                                                                            font-weight: normal;
                                                                        }
                                                                        .datagrid table tbody .alt td {
                                                                            background: #E1EEF4;
                                                                            color: #00557F;
                                                                        }
                                                                        .datagrid table tbody td:first-child {
                                                                            border-left: none;
                                                                        }
                                                                        .datagrid table tbody tr:last-child td {
                                                                            border-bottom: none;
                                                                        }
                                                                        </style>                                                                        
                                                                    <title>Venta Diaria Clinica Vespucio</title>
                                                                    </head>
                                                                    <body>';
--            V_ENCABEZADO := REGEXP_REPLACE(V_ENCABEZADO, '[[:space:]]+',' ' );
            V_ENCABEZADO := V_ENCABEZADO||' '|| '<p style="font-family: Verdana, Helvetica, Arial sans-serif;">Estimad@s,</p>';
--            V_ENCABEZADO := REGEXP_REPLACE(V_ENCABEZADO, '[[:space:]]+',' ' );
            V_ENCABEZADO := V_ENCABEZADO||' '|| '<p style="font-family: Verdana, Helvetica, Arial sans-serif;">Se les informa que la Venta y Proyecci&oacute;n del mes hasta el d&iacutea de ayer es la siguiente:</p>  ';
            V_ENCABEZADO := REGEXP_REPLACE(V_ENCABEZADO, '[[:space:]]+',' ' );
            V_ENCABEZADO := TRANSLATE(TRANSLATE(V_ENCABEZADO,CHR(10),' '),CHR(13),' ');            
                           
                    
            V_CUERPO := '<div class="datagrid">
                                                                    <table width="200px">
                                                                      <thead>
                                                                        <tr>
                                                                            <th colspan="5" align="center" style="font-family: Verdana, Helvetica, Arial sans-serif;" >'||TO_CHAR(V_FECHA_PROCESO,'MONTH')||' '|| TO_CHAR(V_FECHA_PROCESO,'YYYY')||'</th>
                                                                        </tr>
                                                                        <tr>
                                                                          <th colspan="2" align="center">DIA</th>
                                                                          <th align="center">HOSP</th>
                                                                          <th align="center">AMB</th>
                                                                          <th align="center">TOTAL</th>
                                                                        </tr>
                                                                      </thead>
                                                                      <tbody>'; 
--            V_ENCABEZADO := REGEXP_REPLACE(V_ENCABEZADO, '[[:space:]]+',' ' );                                                                                                                                       
                                                             
            FOR C_VENTA IN (
                                            SELECT 
                                                        NVL(TO_CHAR(TO_NUMBER(TO_CHAR(FECHA,'DD'))),'Total:') DIA,
                                                        CASE WHEN FECHA >= TRUNC(V_FECHA_ACTUAL_SISTEMA) THEN NVL(SUBSTR(TO_CHAR(FECHA,'DAY'),1,2),'')||'(p)' ELSE NVL(SUBSTR(TO_CHAR(FECHA,'DAY'),1,2),'') END DS,
                                                        HOSP,AMB,TOTAL,
                                                        ROW_NUMBER() OVER(ORDER BY FECHA) ID_FILA,
                                                        COUNT(*) OVER () TOT_FILAS,
                                                        FECHA
                                            FROM
                                                    (
                                                        SELECT
                                                                    FECHA,
                                                                    REPLACE(TO_CHAR(HOSP, '999,999,999,999'),',','.') HOSP,
                                                                    REPLACE(TO_CHAR(AMB, '999,999,999,999'),',','.')   AMB,
                                                                    REPLACE(TO_CHAR(TOTAL, '999,999,999,999'),',','.') TOTAL
                                                        FROM
                                                                    (                                                     
                                                                    SELECT 
                                                                                FECHA,
                                                                                SUM(HOSP) HOSP,
                                                                                SUM(AMB) AMB,
                                                                                SUM(TOTAL) TOTAL
                                                                    FROM
                                                                                ( 
                                                                                SELECT
                                                                                        F.FECHA,
                                                                                        SUM(CASE WHEN OV.TIPO_VENTA = 'HOSP' THEN VR.NETO ELSE 0 END) HOSP,
                                                                                        SUM(CASE WHEN OV.TIPO_VENTA = 'AMB' THEN VR.NETO ELSE 0 END)  AMB,
                                                                                        SUM(VR.NETO) TOTAL
                                                                                FROM
                                                                                      DM_ORIGEN_VENTA OV,
                                                                                      DM_FECHA F,
                                                                                      FTC_VENTA_RESUMEN VR
                                                                                WHERE
                                                                                        1=1
                                                                                        AND  VR.SID_ORIGEN_VENTA  = OV.SID_ORIGEN_VENTA 
                                                                                        AND  F.SID_FECHA=VR.SID_FECHA 
--                                                                                        AND F.FECHA BETWEEN TRUNC(V_FECHA_PROCESO,'MM') AND V_FECHA_ACTUAL_SISTEMA
                                                                                        AND F.FECHA >= TRUNC(V_FECHA_PROCESO,'MM') 
                                                                                        AND F.FECHA <  V_FECHA_ACTUAL_SISTEMA -1     
                                                                                        AND VR.SID_ORIGEN_VENTA NOT IN (
                                                                                                                                                    14  /*  (+) VENTA OMESA AMB. 01-12-2015: Se saca Venta Omesa, ya que se duplica el último día del mes.*/ 
                                                                                                                                                    )                                                                                                                                                                          
                                                                                GROUP BY 
                                                                                        F.FECHA
                                                                                UNION ALL
                                                                                SELECT
                                                                                VP.FECHA_PROYECTADA,
                                                                                SUM(CASE WHEN VP.TIPO_VENTA = 'HOSP' THEN VP.VENTA_PROYECTADA_FINAL END)  HOSP,
                                                                                SUM(CASE WHEN VP.TIPO_VENTA = 'AMB' THEN VP.VENTA_PROYECTADA_FINAL END )   AMB,
                                                                                SUM(CASE WHEN VP.TIPO_VENTA = 'HOSP' THEN VP.VENTA_PROYECTADA_FINAL END) + SUM(CASE WHEN VP.TIPO_VENTA = 'AMB' THEN VP.VENTA_PROYECTADA_FINAL END ) TOTAL 
                                                                                 FROM 
                                                                                STAGE.VENTA_PROYECTADA VP
                                                                                WHERE
                                                                                FECHA_PROCESO = TRUNC(V_FECHA_ACTUAL_SISTEMA)  
                                                                                AND VP.FECHA_PROYECTADA <= LAST_DAY(TRUNC(V_FECHA_PROCESO) )
                                                                                GROUP BY
                                                                                VP.FECHA_PROYECTADA
                                                                                ORDER BY 1
                                                                                )    
                                                                                 GROUP BY 
                                                                                        (FECHA)
                                                                    )                                                                 
                                                        )            
                                             )        
            LOOP
                            DBMS_OUTPUT.PUT_LINE('C_VENTA.FECHA:  '|| C_VENTA.FECHA); 
                            V_TOT_HOSP :=  V_TOT_HOSP   +  TO_NUMBER(C_VENTA.HOSP, '999,999,999,999');
                            V_TOT_AMB   :=  V_TOT_AMB     + TO_NUMBER(C_VENTA.AMB, '999,999,999,999');
                            V_TOT_TOTAL := V_TOT_TOTAL + TO_NUMBER(C_VENTA.TOTAL, '999,999,999,999');            
--                            DBMS_OUTPUT.PUT_LINE('V_TOT_AMB:  '|| TO_CHAR(V_TOT_AMB));           
--                            DBMS_OUTPUT.PUT_LINE(TO_CHAR(V_TOT_AMB));        
                              DBMS_OUTPUT.PUT_LINE('C_VENTA.AMB:  '|| C_VENTA.AMB); 
                                    
                            IF C_VENTA.FECHA < TRUNC(V_FECHA_ACTUAL_SISTEMA) THEN /*VENTA DE FECHAS REALES QUE YA PASARON VAN A COLOR*/
--                                            DBMS_OUTPUT.PUT_LINE(' IF C_VENTA.FECHA < TRUNC(V_FECHA_ACTUAL_SISTEMA) THEN /*VENTA DE FECHAS REALES QUE YA PASARON VAN A COLOR*/ '); 
                                                
                                            V_SUBTOT_HOSP :=  V_SUBTOT_HOSP   +  TO_NUMBER(C_VENTA.HOSP, '999,999,999,999');
                                            V_SUBTOT_AMB   :=  V_SUBTOT_AMB     + TO_NUMBER(C_VENTA.AMB, '999,999,999,999');
                                            V_SUBTOT_TOTAL := V_SUBTOT_TOTAL + TO_NUMBER(C_VENTA.TOTAL, '999,999,999,999');
                                    
                                            IF MOD(C_VENTA.ID_FILA,2) = 0 THEN /*SI ULTIMA FILA ES PAR FONDO ES DE COLOR:*/
                                                V_CUERPO := (V_CUERPO||' '||
                                                                                                 '<tr class= "alt">'||
                                                                                                      '<td style="text-align: right;">'||C_VENTA.DIA||'</td>
                                                                                                      <td style="text-align: right;">'||C_VENTA.DS||'</td>
                                                                                                      <td style="text-align: right;">'||C_VENTA.HOSP||'</td>
                                                                                                      <td style="text-align: right;">'||C_VENTA.AMB||'</td>
                                                                                                      <td style="text-align: right;">'||C_VENTA.TOTAL||'</td>'||                                      
                                                                                                  '</tr>');       
                                        ELSE
                                                V_CUERPO := (V_CUERPO||' '|| /*SI ULTIMA FILA ES IMPAR FONDO ES BLANCO:*/
                                                                                                 '<tr>'||
                                                                                                      '<td style="text-align: right;">'||C_VENTA.DIA||'</td>
                                                                                                      <td style="text-align: right;">'||C_VENTA.DS||'</td>
                                                                                                      <td style="text-align: right;">'||C_VENTA.HOSP||'</td>
                                                                                                      <td style="text-align: right;">'||C_VENTA.AMB||'</td>
                                                                                                      <td style="text-align: right;">'||C_VENTA.TOTAL||'</td>'||                                      
                                                                                                  '</tr>');     
                                         END IF;  
                                         
                                        V_CUERPO := TRANSLATE(TRANSLATE(V_CUERPO,CHR(10),' '),CHR(13),' ');                                         
                                                
                            ELSE /*VENTA PROYECTADA VA EN GRIS*/
                                              
                                            IF MOD(C_VENTA.ID_FILA,2) = 0 THEN /*SI ULTIMA FILA ES PAR FONDO ES DE COLOR:*/
                                                V_CUERPO := (V_CUERPO||' '||
                                                                                                 '<tr class= "alt">'||
                                                                                                      '<td style="text-align: right; color:#B3B3B3">'||C_VENTA.DIA||'</td>
                                                                                                      <td style="text-align: right; color:#B3B3B3">'||C_VENTA.DS||'</td>
                                                                                                      <td style="text-align: right; color:#B3B3B3">'||C_VENTA.HOSP||'</td>
                                                                                                      <td style="text-align: right; color:#B3B3B3">'||C_VENTA.AMB||'</td>
                                                                                                      <td style="text-align: right; color:#B3B3B3">'||C_VENTA.TOTAL||'</td>'||                                      
                                                                                                  '</tr>');       
                                        ELSE 
                                                V_CUERPO := (V_CUERPO||' '|| /*SI ULTIMA FILA ES IMPAR FONDO ES BLANCO:*/
                                                                                                 '<tr>'||
                                                                                                      '<td style="text-align: right; color:#B3B3B3">'||C_VENTA.DIA||'</td>
                                                                                                      <td style="text-align: right; color:#B3B3B3">'||C_VENTA.DS||'</td>
                                                                                                      <td style="text-align: right; color:#B3B3B3">'||C_VENTA.HOSP||'</td>
                                                                                                      <td style="text-align: right; color:#B3B3B3">'||C_VENTA.AMB||'</td>
                                                                                                      <td style="text-align: right; color:#B3B3B3">'||C_VENTA.TOTAL||'</td>'||                                      
                                                                                                  '</tr>');     
                                         END IF;                                                                                                                                                                                                                                                                                                                   
--                                    DBMS_OUTPUT.PUT_LINE(TO_CHAR(V_TOT_AMB));       
                            END IF;
                                                
                           V_CUERPO := TRANSLATE(TRANSLATE(V_CUERPO,CHR(10),' '),CHR(13),' ');                    

            END LOOP;
                    
            
                                                                                                                            /*ESCRIBE SUBTOTALES Y TOTAL*/
                                                                                                                            
            V_ES_DIA_PAR := MOD(TO_NUMBER(TO_CHAR(LAST_DAY(V_FECHA_PROCESO),'DD')),2) = 0; /* ¿ULTIMO DIA DEL MES ES PAR? */
                                                                                                                                        
--        IF TO_NUMBER(TO_CHAR(V_FECHA_PROCESO,'DD')) = 1 THEN /*SI DIA ACTUAL ES EL PRIMER DIA DEL MES NO MOSTRAR EL SUBTOTAL*/
                                                                                                                                    
        IF LAST_DAY(V_FECHA_ACTUAL_SISTEMA) > LAST_DAY(V_FECHA_PROCESO) THEN /*SI ES EL ULTIMO DIA DEL MES*/
        
                     IF V_ES_DIA_PAR THEN
                     
                                        /*VENTA OMESA*/                                                                                                  
                                        V_CUERPO := (V_CUERPO||' '||
                                                                                         '<tr>'||
                                                                                              '<td colspan="2" style="text-align: right;font-weight: normal; color:#B3B3B3;">'||'Margen OMESA:'||'</td>
                                                                                              <td style="text-align: right; font-weight: normal; color:#B3B3B3;">'||REPLACE(TO_CHAR(                        0               , '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: normal; color:#B3B3B3;">'||REPLACE(TO_CHAR(V_TOT_VENTA_OMESA, '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: normal; color:#B3B3B3;">'||REPLACE(TO_CHAR(V_TOT_VENTA_OMESA, '999,999,999,999'),',','.')||'</td>'||                                      
                                                                                          '</tr>');                     
                            
                                        /*TOTAL DEL MES*/
                                        V_CUERPO := (V_CUERPO||' '||
                                                                                         '<tr class= "alt">'||
                                                                                              '<td colspan="2" style="text-align: right;font-weight: bold;">'||'Total Mes:'||'</td>
                                                                                              <td style="text-align: right; font-weight: bold;">'||REPLACE(TO_CHAR(V_TOT_HOSP, '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: bold;">'||REPLACE(TO_CHAR(V_TOT_AMB     + V_TOT_VENTA_OMESA, '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: bold;">'||REPLACE(TO_CHAR(V_TOT_TOTAL + V_TOT_VENTA_OMESA, '999,999,999,999'),',','.')||'</td>'||                                      
                                                                                          '</tr>'||
                                                                                          
                                           /*PPTO MES*/                                               
                                                                                          '<tr> 
                                                                                               <td colspan="2" style="text-align: right;font-weight: bold;">'||'PPTO:'||'</td>
                                                                                                <td style="text-align: right;font-weight: bold;">'||REPLACE(TO_CHAR(V_TOT_PPTO_VTA_HOSP, '999,999,999,999'),',','.')||'</td>
                                                                                                <td style="text-align: right;font-weight: bold;">'||REPLACE(TO_CHAR(V_TOT_PPTO_VTA_AMB, '999,999,999,999'),',','.')||'</td>
                                                                                                <td style="text-align: right;font-weight: bold;">'||REPLACE(TO_CHAR(V_TOT_PPTO_VENTA, '999,999,999,999'),',','.')||'</td>
                                                                                          </tr>'                                                                                           
                                                                                          );            
                                                                                          
                                    V_CUERPO := TRANSLATE(TRANSLATE(V_CUERPO,CHR(10),' '),CHR(13),' ');                                                                                          
                                                                                          
                     ELSE /*SI DIA ES IMPAR*/      
                     
                     
                     
                                        /*VENTA OMESA*/                                                                                                  
                                        V_CUERPO := (V_CUERPO||' '||
                                                                                         '<tr class= "alt">'||
                                                                                              '<td colspan="2" style="text-align: right;font-weight: normal; color:#B3B3B3;">'||'Margen OMESA:'||'</td>
                                                                                              <td style="text-align: right; font-weight: normal; color:#B3B3B3;">'||REPLACE(TO_CHAR(                        0               , '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: normal; color:#B3B3B3;">'||REPLACE(TO_CHAR(V_TOT_VENTA_OMESA, '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: normal; color:#B3B3B3;">'||REPLACE(TO_CHAR(V_TOT_VENTA_OMESA, '999,999,999,999'),',','.')||'</td>'||                                      
                                                                                          '</tr>');                     
                            
                                        /*TOTAL DEL MES*/
                                        V_CUERPO := (V_CUERPO||' '||
                                                                                         '<tr>'||
                                                                                              '<td colspan="2" style="text-align: right;font-weight: bold;">'||'Total Mes:'||'</td>
                                                                                              <td style="text-align: right; font-weight: bold;">'||REPLACE(TO_CHAR(V_TOT_HOSP, '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: bold;">'||REPLACE(TO_CHAR(V_TOT_AMB     + V_TOT_VENTA_OMESA, '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: bold;">'||REPLACE(TO_CHAR(V_TOT_TOTAL + V_TOT_VENTA_OMESA, '999,999,999,999'),',','.')||'</td>'||                                      
                                                                                          '</tr>'||
                                                                                          
                                           /*PPTO MES*/                                               
                                                                                          '<tr class= "alt"> 
                                                                                               <td colspan="2" style="text-align: right;font-weight: bold;">'||'PPTO:'||'</td>
                                                                                                <td style="text-align: right;font-weight: bold;">'||REPLACE(TO_CHAR(V_TOT_PPTO_VTA_HOSP, '999,999,999,999'),',','.')||'</td>
                                                                                                <td style="text-align: right;font-weight: bold;">'||REPLACE(TO_CHAR(V_TOT_PPTO_VTA_AMB, '999,999,999,999'),',','.')||'</td>
                                                                                                <td style="text-align: right;font-weight: bold;">'||REPLACE(TO_CHAR(V_TOT_PPTO_VENTA, '999,999,999,999'),',','.')||'</td>
                                                                                          </tr>'                                                                                           
                                                                                          );
                                                                                          
                                    V_CUERPO := TRANSLATE(TRANSLATE(V_CUERPO,CHR(10),' '),CHR(13),' ');                                                                                               
                     END IF;      
                     
                     V_CUERPO := TRANSLATE(TRANSLATE(V_CUERPO,CHR(10),' '),CHR(13),' ');                                                                   
                                                                                                                                                                                      
        ELSE /*SI NO ES ULTIMO DIA DEL MES */ 
        
                    IF V_ES_DIA_PAR THEN

                                        /*SUBTOTAL A LA FECHA*/
                                        V_CUERPO := (V_CUERPO||' '||
                                                                                         '<tr>'||
                                                                                              '<td colspan="2" style="text-align: right;font-weight: bold;">'||'Sub-Total al d&iacute;a '||TO_CHAR(V_FECHA_PROCESO,'DD') ||' :'||'</td>
                                                                                              <td style="text-align: right; font-weight: bold;">'||REPLACE(TO_CHAR(V_SUBTOT_HOSP, '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: bold;">'||REPLACE(TO_CHAR(V_SUBTOT_AMB, '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: bold;">'||REPLACE(TO_CHAR(V_SUBTOT_TOTAL, '999,999,999,999'),',','.')||'</td>'||                                      
                                                                                          '</tr>');                        
                    
                                        /*VENTA OMESA*/                                                                                                  
                                        V_CUERPO := (V_CUERPO||' '||
                                                                                         '<tr class= "alt">'||
                                                                                              '<td colspan="2" style="text-align: right;font-weight: normal; color:#B3B3B3;">'||'Margen OMESA:'||'</td>
                                                                                              <td style="text-align: right; font-weight: normal; color:#B3B3B3;">'||REPLACE(TO_CHAR(                        0               , '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: normal; color:#B3B3B3;">'||REPLACE(TO_CHAR(V_TOT_VENTA_OMESA, '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: normal; color:#B3B3B3;">'||REPLACE(TO_CHAR(V_TOT_VENTA_OMESA, '999,999,999,999'),',','.')||'</td>'||                                      
                                                                                          '</tr>');                     
                            
                                        /*TOTAL DEL MES*/
                                        V_CUERPO := (V_CUERPO||' '||
                                                                                         '<tr>'||
                                                                                              '<td colspan="2" style="text-align: right;font-weight: bold; color:#B3B3B3;">'||'Total Mes Proy:'||'</td>
                                                                                              <td style="text-align: right; font-weight: bold; color:#B3B3B3;">'||REPLACE(TO_CHAR(V_TOT_HOSP, '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: bold; color:#B3B3B3;">'||REPLACE(TO_CHAR(V_TOT_AMB     + V_TOT_VENTA_OMESA, '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: bold; color:#B3B3B3;">'||REPLACE(TO_CHAR(V_TOT_TOTAL + V_TOT_VENTA_OMESA, '999,999,999,999'),',','.')||'</td>'||                                      
                                                                                          '</tr>'||
                                                                                          
                                           /*PPTO MES*/                                               
                                                                                          '<tr class= "alt"> 
                                                                                               <td colspan="2" style="text-align: right;font-weight: bold;">'||'PPTO:'||'</td>
                                                                                                <td style="text-align: right;font-weight: bold;">'||REPLACE(TO_CHAR(V_TOT_PPTO_VTA_HOSP, '999,999,999,999'),',','.')||'</td>
                                                                                                <td style="text-align: right;font-weight: bold;">'||REPLACE(TO_CHAR(V_TOT_PPTO_VTA_AMB, '999,999,999,999'),',','.')||'</td>
                                                                                                <td style="text-align: right;font-weight: bold;">'||REPLACE(TO_CHAR(V_TOT_PPTO_VENTA, '999,999,999,999'),',','.')||'</td>
                                                                                          </tr>'                                                                                           
                                                                                          );     
                                    V_CUERPO := TRANSLATE(TRANSLATE(V_CUERPO,CHR(10),' '),CHR(13),' ');                                                                                                  
                                                                                          
                    ELSE /* SI DIA ES IMPAR*/
                                                
                                        /*SUBTOTAL A LA FECHA*/
                                        V_CUERPO := (V_CUERPO||' '||
                                                                                         '<tr class= "alt">'||
                                                                                              '<td colspan="2" style="text-align: right;font-weight: bold;">'||'Sub-Total al d&iacute;a '||TO_CHAR(V_FECHA_PROCESO,'DD') ||' :'||'</td>
                                                                                              <td style="text-align: right; font-weight: bold;">'||REPLACE(TO_CHAR(V_SUBTOT_HOSP, '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: bold;">'||REPLACE(TO_CHAR(V_SUBTOT_AMB, '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: bold;">'||REPLACE(TO_CHAR(V_SUBTOT_TOTAL, '999,999,999,999'),',','.')||'</td>'||                                      
                                                                                          '</tr>');                        
                    
                                        /*VENTA OMESA*/                                                                                                  
                                        V_CUERPO := (V_CUERPO||' '||
                                                                                         '<tr>'||
                                                                                              '<td colspan="2" style="text-align: right;font-weight: normal; color:#B3B3B3;">'||'Margen OMESA:'||'</td>
                                                                                              <td style="text-align: right; font-weight: normal; color:#B3B3B3;">'||REPLACE(TO_CHAR(                        0               , '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: normal; color:#B3B3B3;">'||REPLACE(TO_CHAR(V_TOT_VENTA_OMESA, '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: normal; color:#B3B3B3;">'||REPLACE(TO_CHAR(V_TOT_VENTA_OMESA, '999,999,999,999'),',','.')||'</td>'||                                      
                                                                                          '</tr>');                     
                            
                                        /*TOTAL DEL MES*/
                                        V_CUERPO := (V_CUERPO||' '||
                                                                                         '<tr class= "alt">'||
                                                                                              '<td colspan="2" style="text-align: right;font-weight: bold; color:#B3B3B3;">'||'Total Mes Proy:'||'</td>
                                                                                              <td style="text-align: right; font-weight: bold; color:#B3B3B3;">'||REPLACE(TO_CHAR(V_TOT_HOSP, '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: bold; color:#B3B3B3;">'||REPLACE(TO_CHAR(V_TOT_AMB     + V_TOT_VENTA_OMESA, '999,999,999,999'),',','.')||'</td>
                                                                                              <td style="text-align: right; font-weight: bold; color:#B3B3B3;">'||REPLACE(TO_CHAR(V_TOT_TOTAL + V_TOT_VENTA_OMESA, '999,999,999,999'),',','.')||'</td>'||                                      
                                                                                          '</tr>'||
                                                                                          
                                           /*PPTO MES*/                                               
                                                                                          '<tr> 
                                                                                               <td colspan="2" style="text-align: right;font-weight: bold;">'||'PPTO:'||'</td>
                                                                                                <td style="text-align: right;font-weight: bold;">'||REPLACE(TO_CHAR(V_TOT_PPTO_VTA_HOSP, '999,999,999,999'),',','.')||'</td>
                                                                                                <td style="text-align: right;font-weight: bold;">'||REPLACE(TO_CHAR(V_TOT_PPTO_VTA_AMB, '999,999,999,999'),',','.')||'</td>
                                                                                                <td style="text-align: right;font-weight: bold;">'||REPLACE(TO_CHAR(V_TOT_PPTO_VENTA, '999,999,999,999'),',','.')||'</td>
                                                                                          </tr>'                                                                                           
                                                                                          );         
                                        V_CUERPO := TRANSLATE(TRANSLATE(V_CUERPO,CHR(10),' '),CHR(13),' ');                                                                                                                                                                          
                                                                                            
                     END IF;
                     
                    V_CUERPO := TRANSLATE(TRANSLATE(V_CUERPO,CHR(10),' '),CHR(13),' ');   

         END IF;    
          
                                                                            
            V_CUERPO := TRANSLATE(TRANSLATE(V_CUERPO,CHR(10),' '),CHR(13),' ');    
--            V_CUERPO := REGEXP_REPLACE(V_CUERPO, '[[:space:]]+',' ' );
            
            V_PIE:=  '</tbody></table></div>
                                    <p style="font-family: Verdana, Helvetica, Arial sans-serif;">(p) = Venta Proyectada </p>
                                    <div  style="width: 100%;"><p align="center"><img src="http://www.clinicavespucio.cl/wp-content/themes/clinica_vespucio/images/logo_clinica_vespucio.svg" alt="logo clinica" /></div>
                                <br><br><br>
                            </body></html>' ;         

            V_PIE := TRANSLATE(TRANSLATE(V_PIE,CHR(10),' '),CHR(13),' ');        
            V_PIE := REGEXP_REPLACE(V_PIE, '[[:space:]]+',' ' );                  

--        DBMS_OUTPUT.PUT_LINE('1: PASO  ');         
        
        DBMS_LOB.WRITE (V_MENSAJE,  LENGTH(V_ENCABEZADO),  DBMS_LOB.GETLENGTH (V_MENSAJE) + 1,   V_ENCABEZADO );        
        DBMS_LOB.WRITE (V_MENSAJE,  LENGTH(V_CUERPO),  DBMS_LOB.GETLENGTH (V_MENSAJE) + 1,   V_CUERPO );   
        DBMS_LOB.WRITE (V_MENSAJE,  LENGTH(V_PIE),  DBMS_LOB.GETLENGTH (V_MENSAJE) + 1,   V_PIE );     
       
        
              GENERALES.P_ENVIAR_EMAIL_CLOB( 
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
                                                                                                ||'jcanto@clinicavespucio.cl;'
                                                                                                ||'cloyola@clinicavespucio.cl;'
                                                                                                ||'lortega@clinicavespucio.cl;'
                                                                                                ||'cgarcia@clinicavespucio.cl;'
                                                                                                ||'alvaro.figueroa@clinicavespucio.cl;'         
                                                                                                ||'fhernandezg@clinicavespucio.cl;'  
                                                                                                /**/                                                                                       
                                                                                                ||'pcurinao@clinicavespucio.cl',              
                                                                                                
--                                                                                p_to             => 'juansabajmanzur@gmail.com;pcurinao@clinicavespucio.cl;pcurinao@gmail.com;edison.carrizo.j@gmail.com;ecarrizo@clinicavespucio.cl;smella@fen.uchile.cl;smella@clinicavespucio.cl',                                                      
--                                                                              p_to             => 'juansabajmanzur@gmail.com;pcurinao@gmail.com;smella@fen.uchile.cl;edison.carrizo.j@gmail.com;ecarrizo@clinicavespucio.cl',
--                                                                            p_to             => 'pcurinao@clinicavespucio.cl',
--                                                                            p_to             => 'pcurinao@clinicavespucio.cl;smella@clinicavespucio.cl',
--                                                                            p_to             => 'jsabaj@clinicavespucio.cl;pcurinao@clinicavespucio.cl;smella@clinicavespucio.cl',
--                                                                            p_to             => 'pcurinao@clinicavespucio.cl;pcurinao@gmail.com',
--                                                                            p_to             => 'pcurinao@clinicavespucio.cl;pcurinao@gmail.com;smella@fen.uchile.cl',
--                                                                            p_to             => 'pcurinao@clinicavespucio.cl;pcurinao@gmail.com;edison.carrizo.j@gmail.com;ecarrizo@clinicavespucio.cl;ecarrizo@clinicavespucio.tigabytes.cl',
                                                                            p_from         => 'servidor.gestion@clinicavespucio.com',
                                                                            p_subject     => 'Resumen Venta Diaria al '||TO_CHAR(V_FECHA_PROCESO,'DD')||'-'||SUBSTR(TRIM(INITCAP(TO_CHAR(V_FECHA_PROCESO,'MONTH'))),1,3)||'-'|| TO_CHAR(V_FECHA_PROCESO,'YYYY')||'   (mobile)' ,
                                                                            p_msg => V_MENSAJE,
                                                                            p_alias          => 'Venta'   
--                                                                            p_alias          => 'Venta (Reemplaza Proy. por Forecast)'   
                                                                          );        

END;
/
show errors

--EXECUTE P_ENVIAR_MAIL_VENTA_DIARIA;



