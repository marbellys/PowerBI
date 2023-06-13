--Desde ORACLE
--v.2

--Desde ORACLE

SELECT  pe.FECFIN Fecha, n.TRAB_FICTRA as  EmplID, 
       CASE (SUBSTR(n.TRAB_FICTRA,1,1))
		  WHEN 'C' THEN 'CONTRATADO'
		  WHEN 'A' THEN 'APRENDIZ'
		  ELSE 'FIJO' END TipoPersonal,  
	   n.TNOM_TIPNOM tipoNomina,
	   n.FPRO_ANOCAL AñoProceso,
	   n.PROC_TIPPRO TipoProceso,
	   n.DPTO_CODDEP CodDpto,
	   n.FECSAL FecIniVac,
	   n.FECREG FecRegVac,
	   n.STAT_CODVAC Vacaciones,
	   n.FECING FecIng,
	  -- n.TOASIG Asignaciones,
	  -- n.TODEDU Deducciones,
	  -- n.TONETO TotalNeto,
	   n.DGRT_CODGRU IdGrupo, g.DESGRU Grupo,
	   n.CGO_CODCAR IdCargo, c.NOMBRE Cargo,
	   n.ID_PUESTO IdPuesto, p.NOMBRE Puesto,
	   n.DPTO_CODDEP, u.NOMBRE Departamento,
           ne.FECRET,  
	   CASE
		  WHEN (ne.FECRET IS NOT NULL)  THEN 
		     CASE  
		       WHEN (rl.ID_FINIQUITO IS NULL)  THEN  '1'
		       WHEN (rl.ID_FINIQUITO IS NOT  NULL)  THEN  rl.ID_FINIQUITO
		       ELSE rl.ID_FINIQUITO 
		     END 
		  WHEN (ne.FECRET IS NULL) THEN NULL 
		  ELSE rl.ID_FINIQUITO 
		  END ID_FINIQUITO, 
		CASE
		  WHEN (ne.FECRET IS NOT NULL)  THEN 
		     CASE  
		       WHEN (rl.ID_FINIQUITO IS NULL)  THEN  'RENUNCIA'
		       WHEN (rl.ID_FINIQUITO IS NOT  NULL)  THEN   rr.DESDE1
		       ELSE  rr.DESDE1 
		     END 
		  WHEN (ne.FECRET IS NULL) THEN NULL 
		  ELSE  rr.DESDE1 
		  END MotivoFin, 
	   ne.FECNAC,ne.SEXO, 
           round((TRUNC(SYSDATE) - ne.FECNAC) / 365)  edad,
       NVL(ne.nivedu,9) IdNivEduc,  NVL(ed.DESNIV,'SIN DATOS') NivelEduc,
	   NVL(ne.PFS_CODPRF,9) IdProf, NVL(pr.DESPRF,'SIN DATOS') Profesion,
	   to_char(NVL(s.SUEDIA*30,1000),'999999999G00') SueldoMes
FROM INFOCENT.NMM023 n,INFOCENT.NMT033 pe, INFOCENT.NM_EMPLEADO ne, INFOCENT.NMT023 g, INFOCENT.NMT057 ed, 
     INFOCENT.NMT045 pr, INFOCENT.EO_CARGO c, INFOCENT.EO_UNIDAD u, INFOCENT.EO_PUESTO p,INFOCENT.TA_RELACION_LABORAL rl, 
     INFOCENT.NMT035 rr, INFOCENT.NMM004_RESP s
WHERE n.CIA_CODCIA ='01'
AND n.TNOM_TIPNOM IN ('EREG','INDI','COLE','ADIZ','JUBI','APRE')
AND n.PROC_TIPPRO IN (1,2,4,5)
AND n.SUBPRO IN (0)
AND n.FPRO_ANOCAL BETWEEN 2017 AND 2022    
AND pe.ESTPER = '1'
AND pe.CIA_CODCIA = n.CIA_CODCIA
AND pe.TNOM_TIPNOM = n.TNOM_TIPNOM 
AND pe.PROC_TIPPRO = n.PROC_TIPPRO 
AND pe.SUBPRO  = n.SUBPRO 
AND pe.ANOCAL  = n.FPRO_ANOCAL 
AND pe.NUMPER  = n.FPRO_NUMPER 
AND ne.CIA_CODCIA = n.CIA_CODCIA
AND ne.FICHA = n.TRAB_FICTRA
AND n.CIA_CODCIA =g.CIA_CODCIA
AND n.TNOM_TIPNOM  = g.TNOM_TIPNOM
AND n.DGRT_CODGRU  = g.CODGRU
AND ne.NIVEDU = ed.CODNIV(+) 
AND ne.PFS_CODPRF = pr.CODPRF(+)
AND n.CGO_CODCAR   = c.ID (+)
AND n.CIA_CODCIA  = c.ID_EMPRESA 
AND n.CIA_CODCIA  = u.ID_EMPRESA 
AND n.DPTO_CODDEP = u.ID(+) --
AND n.CIA_CODCIA = p.ID_EMPRESA 
AND n.DPTO_CODDEP  = p.ID_UNIDAD 
AND n.ID_PUESTO  = p.ID(+) -- 
AND n.CIA_CODCIA  = rl.ID_EMPRESA
AND n.TRAB_FICTRA  = rl.FICHA
AND rl.ID_FINIQUITO = rr.CODDES(+)   
AND s.CIA_CODCIA = n.CIA_CODCIA 
AND s.TRAB_SUBTIP = n.TRAB_SUBTIP 
AND s.TRAB_FICTRA = n.TRAB_FICTRA 
AND s.TIPSUE  = '1'
AND s.fecaum = (SELECT MAX(s2.fecaum)
                                   FROM   NMM004_RESP s2
                                   WHERE  s2.cia_codcia = s.cia_codcia
                                   AND    s2.trab_subtip = s.trab_subtip
                                   AND    s2.trab_fictra = s.trab_fictra
                                   AND    s2.tipsue = '1'--s.tipsue
                                   AND    s2.fecaum <= pe.FECFIN)  
                                   
--AND n.TRAB_FICTRA ='00070'
                                 
ORDER BY  fecha,EmplID
