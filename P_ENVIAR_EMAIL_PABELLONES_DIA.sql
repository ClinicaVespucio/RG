set define off;

CREATE OR REPLACE PROCEDURE DW.P_ENVIAR_EMAIL_PABELLONES_DIA AS

V_ENCABEZADO VARCHAR2(32767);
V_CUERPO VARCHAR2(32767);
V_PIE VARCHAR2(32767);
V_MENSAJE CLOB := ' '; 

BEGIN

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
                                                                    <title>Actividad y Reserva Pabellones Clinica Vespucio</title>
                                                                    </head>
                                                                    <body>';
                                                                    
            V_ENCABEZADO := V_ENCABEZADO||chr(10);                                                    
            V_ENCABEZADO := REGEXP_REPLACE(V_ENCABEZADO, '[[:space:]]+',' ' );
            DBMS_LOB.WRITE (V_MENSAJE,   LENGTH(V_ENCABEZADO),   1,   V_ENCABEZADO );    /*PRIMERA CADENA DE TEXTO CLOB*/          
                        
            V_ENCABEZADO := V_ENCABEZADO||' '|| '<p style="font-family: Verdana, Helvetica, Arial sans-serif;">Estimad@s,</p>';
            V_ENCABEZADO := REGEXP_REPLACE(V_ENCABEZADO, '[[:space:]]+',' ' );
            V_ENCABEZADO := V_ENCABEZADO||' '|| '<p style="font-family: Verdana, Helvetica, Arial sans-serif;">Les informamos que la actividad de pabellones del mes hasta el dia de ayer + la reserva de pabellones de todo el mes, es la siguiente:</p>  ';
            V_ENCABEZADO := REGEXP_REPLACE(V_ENCABEZADO, '[[:space:]]+',' ' );
                                   
            V_ENCABEZADO := V_ENCABEZADO||' '||'<div class="datagrid">
                                                                    <table width="200px">
                                                                      <thead>
                                                                        <tr>
                                                                            <th colspan="8" align="center" style="font-family: Verdana, Helvetica, Arial sans-serif;" >'||TO_CHAR(SYSDATE-1,'MONTH')||' '|| TO_CHAR(SYSDATE-1,'YYYY')||'</th>
                                                                        </tr>
                                                                        <tr>
                                                                            <th colspan="2" rowspan="2" align="center">DIA</th>
                                                                            <th colspan="1" rowspan="2" align="center">RESERVAS (*)</th>
                                                                            <th colspan="4" rowspan="1" align="center">PABELLONES REALIZADOS</th>
                                                                            <th colspan="1" rowspan="2" align="center">% Concretados / Reservas</th>
                                                                        </tr>                                                                        
                                                                        <tr>
                                                                            <th colspan="1" align="center" style="font-family: Verdana, Helvetica, Arial sans-serif;">Concretados</th>
                                                                            <th colspan="1" align="center" style="font-family: Verdana, Helvetica, Arial sans-serif;">Urgencia</th>
                                                                            <th colspan="1" align="center" style="font-family: Verdana, Helvetica, Arial sans-serif;">Parto Cesarea Urgencia</th>
                                                                            <th colspan="1"align="center" style="font-family: Verdana, Helvetica, Arial sans-serif;">TOTAL</th>
                                                                        </tr>                                                                        
                                                                      </thead>
                                                                      <tbody>'; 
                                                                      
            V_ENCABEZADO := REGEXP_REPLACE(V_ENCABEZADO, '[[:space:]]+',' ' );        
            V_ENCABEZADO := TRANSLATE(TRANSLATE(V_ENCABEZADO,CHR(10),' '),CHR(13),' ');     
            
            DBMS_LOB.WRITE (V_MENSAJE,  LENGTH(V_ENCABEZADO),  DBMS_LOB.GETLENGTH (V_MENSAJE) + 1,   V_ENCABEZADO );        
            
            FOR C_PAB IN (
                                            SELECT 
                                                        NVL(TO_CHAR(TO_NUMBER(TO_CHAR(FECHA,'DD'))),'Total:') DIA,
                                                        NVL(SUBSTR(TO_CHAR(FECHA,'DAY'),1,2),'') DS,
                                                        PAB_QUIR,PAB_MATER,TOTAL,ING_URG,TOTAL_SIN_URG,IND_PARTO_ING_URG,PAB_QUIR_R,PAB_MATER_R,TOTAL_R,
                                                        ROW_NUMBER() OVER(ORDER BY FECHA) ID_FILA,
                                                        COUNT(*) OVER () TOT_FILAS
                                            FROM            
                                                        (
                                                            SELECT 
                                                                    FECHA,
                                                                    SUM(PAB_QUIR) PAB_QUIR,
                                                                    SUM(PAB_MATER) PAB_MATER,
                                                                    SUM(TOTAL) TOTAL,
                                                                    SUM(ING_URG) ING_URG,
                                                                    SUM(TOTAL) -  SUM(ING_URG) TOTAL_SIN_URG,    
                                                                    SUM(IND_PARTO_ING_URG) IND_PARTO_ING_URG,                                                                 
                                                                    SUM(PAB_QUIR_R) PAB_QUIR_R,
                                                                    SUM(PAB_MATER_R) PAB_MATER_R,
                                                                    SUM(TOTAL_R) TOTAL_R        
                                                            FROM 
                                                                    (
                                                                    /*PABELLONES EFECTIVOS*/
                                                                    SELECT 
                                                                        TRUNC(PO.FECHA_INICIO_OCUPPAB) FECHA,
                                                                        SUM(CASE WHEN GU.CNEG_UNIDAD = 50001 THEN 1 ELSE 0 END) PAB_QUIR,
                                                                        SUM(CASE WHEN GU.CNEG_UNIDAD = 57001 THEN 1 ELSE 0 END) PAB_MATER,
                                                                        COUNT(*) TOTAL,
                                                                        SUM(CASE WHEN AI.ID_URGENCIA > 0 THEN 1 ELSE 0 END) ING_URG,     
                                                                        SUM( CASE WHEN PO.COD_PRESTACION IN (SELECT 
                                                                                                                                                    LPAD(AP.GRUPO_PRES,2,'00')||'-'||LPAD(AP.TIPO_PRES,2,'00')||'-'||LPAD(AP.CODIGO_PRES,3,'000')||'-'||LPAD(AP.CODADD_PRES,2,'00') COD_PRESTACION
                                                                                                                                                    FROM
                                                                                                                                                    AP_PRESTACIONES @MEDISYN_4.CLONVES AP 
                                                                                                                                                    WHERE
                                                                                                                                                    AP.COD_EMPRESA = 4
                                                                                                                                                    AND GRUPO_PRES = 20
                                                                                                                                                    AND AP.TIPO_PRES = 4
                                                                                                                                                    AND AP.CODIGO_PRES IN (3,5,6)) AND AI.ID_URGENCIA > 0 THEN 1 ELSE 0 END       
                                                                        ) IND_PARTO_ING_URG,                                                                   
                                                                        0 PAB_QUIR_R,
                                                                        0 PAB_MATER_R,
                                                                        0 TOTAL_R
                                                                    FROM
                                                                        PAB_PROTOCOLO_OPERATORIO @MEDISYN_4.CLONVES PO,
                                                                        PAB_PABELLON @MEDISYN_4.CLONVES PP,
                                                                        GEN_UNIDAD @MEDISYN_4.CLONVES GU,
                                                                        ADM_INGRESOS @MEDISYN_4.CLONVES AI
                                                                    WHERE 
                                                                        1=1
                                                                        AND PO.COD_EMPRESA = 4
                                                                        AND PO.COD_SUCURSAL = 1
                                                                        AND PP.COD_EMPRESA = 4
                                                                        AND PP.COD_SUCURSAL = 1
                                                                        AND GU.COD_EMPRESA = 4
                                                                        AND GU.COD_SUCURSAL = 1
                                                                        AND AI.COD_EMPRESA = 4
                                                                        AND AI.COD_SUCURSAL = 1
                                                                        AND AI.ID_INGRESO = PO.ID_INGRESO
                                                                        AND PP.COD_PABELLON = PO.COD_PABELLON
                                                                        AND GU.COD_UNIDAD = PP.COD_UNIDAD
                                                                        AND AI.ID_INGRESO = PO.ID_INGRESO
                                                                        /*AND PO.FECHA_INICIO_OCUPPAB BETWEEN TO_DATE('01/10/2014','dd/mm/yyyy') AND TO_DATE('31/10/2014 23:59:59','dd/mm/yyyy hh24:mi:ss')*/ 
                                                                        AND PO.FECHA_INICIO_OCUPPAB BETWEEN TRUNC(SYSDATE-1,'MM') AND SYSDATE
                                                                        AND PO.ESTADO_PROTOCOLO <> 'ANU'
                                                                    GROUP BY
                                                                        TRUNC(PO.FECHA_INICIO_OCUPPAB) 
                                                                    UNION ALL
                                                                    /*RESERVA DE PABELLONES*/
                                                                    SELECT
                                                                        TRUNC(RP.FECHA_INICIO) FECHA,
                                                                        0 PAB_QUIR,
                                                                        0 PAB_MATER,
                                                                        0 TOTAL,    
                                                                        0 ING_URG,
                                                                        0 IND_PARTO_ING_URG,
                                                                        SUM(CASE WHEN GU.CNEG_UNIDAD = 50001 THEN 1 ELSE 0 END) PAB_QUIR_R,
                                                                        SUM(CASE WHEN GU.CNEG_UNIDAD = 57001 THEN 1 ELSE 0 END) PAB_MATER_R,
                                                                        COUNT(*) TOTAL_R    
                                                                    FROM
                                                                        PAB_RESERVA_PABELLON @MEDISYN_4.CLONVES RP ,
                                                                        PAB_PABELLON @MEDISYN_4.CLONVES PP ,
                                                                        GEN_UNIDAD @MEDISYN_4.CLONVES GU
                                                                    WHERE
                                                                        1=1
                                                                        AND RP.COD_EMPRESA = 4
                                                                        AND RP.COD_SUCURSAL = 1
                                                                        AND PP.COD_EMPRESA = 4
                                                                        AND PP.COD_SUCURSAL = 1
                                                                        AND GU.COD_EMPRESA = 4
                                                                        AND GU.COD_SUCURSAL = 1
                                                                        AND PP.COD_PABELLON = RP.COD_PABELLON
                                                                        AND GU.COD_UNIDAD = PP.COD_UNIDAD
                                                                        AND RP.ESTADO <> 'ANULADO'
                                                                        /*AND RP.FECHA_INICIO BETWEEN TO_DATE('01/10/2014','dd/mm/yyyy') AND TO_DATE('31/10/2014 23:59:59','dd/mm/yyyy hh24:mi:ss')*/ 
                                                                        AND RP.FECHA_INICIO BETWEEN TRUNC(SYSDATE-1,'MM') AND LAST_DAY(TRUNC(SYSDATE)-1) +(1-(((1/24)/60))/60)          
                                                                        AND RP.FECHA_INGRESO <= (TRUNC(RP.FECHA_INICIO)-1) +21/24  /* 26-10-2014. FECHA INGRESO DE LA RESERVA AL SISTEMA NO PUEDE SER MAYOR O IGUAL A LAS 21:00 HRS  DEL DIA ANTERIOR*/                                                                      
                                                                    GROUP BY
                                                                        TRUNC(RP.FECHA_INICIO)
                                                                    ORDER BY 1    
                                                                    )         
                                                            GROUP BY ROLLUP
                                                                    (FECHA)           
                                                            ORDER BY 1        
                                                            )
                                             )        
            LOOP
                                V_CUERPO := 
                                 '<tr class="'||CASE WHEN MOD(C_PAB.ID_FILA,2) = 0 THEN  'alt' ELSE NULL END||'">'||
                                      '<td '||CASE WHEN C_PAB.ID_FILA = C_PAB.TOT_FILAS THEN 'style="text-align:right;font-weight:bold" ' ELSE 'style="text-align:right;"' END||'>'||C_PAB.DIA||'</td>
                                      <td '||CASE WHEN C_PAB.ID_FILA = C_PAB.TOT_FILAS THEN 'style="text-align:left;font-weight:bold" ' ELSE 'style="text-align:right;"' END||'>'||C_PAB.DS||'</td>
                                      <td '||CASE WHEN C_PAB.ID_FILA = C_PAB.TOT_FILAS THEN 'style="text-align:right;font-weight:bold" ' ELSE 'style="text-align:right;"' END||'>'||C_PAB.TOTAL_R||'</td>
                                      <td '||CASE WHEN C_PAB.ID_FILA = C_PAB.TOT_FILAS THEN 'style="text-align:right;font-weight:bold" ' ELSE 'style="text-align:right;"' END||'>'||C_PAB.TOTAL_SIN_URG||'</td>
                                      <td '||CASE WHEN C_PAB.ID_FILA = C_PAB.TOT_FILAS THEN 'style="text-align:right;font-weight:bold" ' ELSE 'style="text-align:right;"' END||'>'||TO_CHAR(C_PAB.ING_URG - C_PAB.IND_PARTO_ING_URG)||'</td>
                                      <td '||CASE WHEN C_PAB.ID_FILA = C_PAB.TOT_FILAS THEN 'style="text-align:right;font-weight:bold" ' ELSE 'style="text-align:right;"' END||'>'||C_PAB.IND_PARTO_ING_URG||'</td>
                                      <td '||CASE WHEN C_PAB.ID_FILA = C_PAB.TOT_FILAS THEN 'style="text-align:right;font-weight:bold" ' ELSE 'style="text-align:right;"' END||'>'||C_PAB.TOTAL||'</td>
                                      <td '||CASE WHEN C_PAB.ID_FILA = C_PAB.TOT_FILAS THEN 'style="text-align:right;font-weight:bold" ' ELSE 'style="text-align:right;"' END||'>'||TO_CHAR(ROUND(CASE WHEN C_PAB.TOTAL_R = 0 THEN 0 ELSE C_PAB.TOTAL_SIN_URG/C_PAB.TOTAL_R END*100,2))||'%</td>'||
                                  '</tr>';
                                  V_CUERPO:= V_CUERPO||chr(13);    
                                  DBMS_LOB.WRITE (V_MENSAJE,  LENGTH(V_CUERPO),  DBMS_LOB.GETLENGTH (V_MENSAJE) + 1,   V_CUERPO );   
   
                                  V_CUERPO := NULL;         
                                 
            END LOOP;
                    
            
            V_PIE:=  '</tbody></table></div>
                                <p style="font-family: Verdana, Helvetica, Arial sans-serif;">(*) Incluye reservas ingresadas al sistema s&oacute;lo hasta las 21:00 horas del d&iacute;a anterior</p>
                                    <div  style="width: 100%;"><p align="center"><img src="http://www.clinicavespucio.cl/wp-content/themes/clinica_vespucio/images/logo_clinica_vespucio.svg" alt="logo clinica" /></div>
                                <br><br><br>
                            </body></html>' ;      
            
            V_PIE := TRANSLATE(TRANSLATE(V_PIE,CHR(10),' '),CHR(13),' ');                    

            DBMS_LOB.WRITE (V_MENSAJE,  LENGTH(V_PIE),  DBMS_LOB.GETLENGTH (V_MENSAJE) + 1,   V_PIE );     

            V_MENSAJE := REGEXP_REPLACE(V_MENSAJE, '\s+('||CHR(10)||'|$)', CHR(10));        
 
                                                                          
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
                                                                                                ||'jcanto@clinicavespucio.cl;'
                                                                                                ||'cloyola@clinicavespucio.cl;'
                                                                                                ||'lortega@clinicavespucio.cl;'
                                                                                                ||'cgarcia@clinicavespucio.cl;'
                                                                                                ||'alvaro.figueroa@clinicavespucio.cl;'
                                                                                                ||'fhernandezg@clinicavespucio.cl;'  
                                                                                                /**/
                                                                                                ||'pcurinao@clinicavespucio.cl',
                                                                                                /**/
--                                                                            p_to            =>  'pcurinao@clinicavespucio.cl',
--                                                                            p_to             => 'pcurinao@clinicavespucio.cl;smella@clinicavespucio.cl',
--                                                                            p_to             => 'juansabajmanzur@gmail.com;pcurinao@clinicavespucio.cl;pcurinao@gmail.com;edison.carrizo.j@gmail.com;ecarrizo@clinicavespucio.cl;smella@fen.uchile.cl;smella@clinicavespucio.cl',
--                                                                            p_to             => 'plezaeta@tisal.com',
                                                                            p_from        => 'servidor.gestion@clinicavespucio.cl',
                                                                            p_subject    => 'Resumen Actividad Diaria Pabellones al '||TO_CHAR(SYSDATE-1,'DD')||'-'||SUBSTR(TRIM(INITCAP(TO_CHAR(SYSDATE-1,'MONTH'))),1,3)||'-'|| TO_CHAR(SYSDATE-1,'YYYY')||' + Reserva Mensual (mobile)' ,
                                                                            p_msg         => V_MENSAJE,
--                                                                            p_msg         => 'Estimados, este reporte est&aacute; moment&aacute;neamente en revisi&oacute;n.',
                                                                            p_alias        => 'Pabellones'
                                                                            );                                                                          
                                                                          

END;
/


SHOW ERRORS


--EXECUTE DW.P_ENVIAR_EMAIL_PABELLONES_DIA;


