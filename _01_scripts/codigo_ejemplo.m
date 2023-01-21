%   TFM - Curso 2016-2017
%
%   Código de la comparación de las tecncias de calibración para días
%   tranquilos y días perturbados por la tormenta de 2015
%

clear all
close all

yyyy=2015; %Año
stn='ieng';    %Estacion:

dia=22;               %Dias perturbados
for k=83
    n=0; N=0;
ddd=num2str(k);
dia=dia+1; di=num2str(dia);
%Cargamos los datos de GOPI:
 g=fopen([stn,'0',ddd,'-2015-03-',di,'.Cmn'],'rt');
 formato = '%f %f %f %f %f %f %f %f %f %f %f';
 datosGO = textscan(g, formato, 'HeaderLines', 5); 
% definimos las variables de Gopi      
  Jdate=datosGO{1,1};
  ep=datosGO{1,2};
  ep(1,1)=0;    % en Gopi la epoca t=0 aparece como -24, lo cambiamos
  ep(:,1)=ep(:,1).*3600; ep=round(ep);
  prnGopi=datosGO{1,3};
  aziGopi=datosGO{1,4};
  eleGoppi=datosGO{1,5};
  latGopi=datosGO{1,6};
  longGopi=datosGO{1,7};
  sTECGO=datosGO{1,8};
  vTECGopi=datosGO{1,9};
  s4=datosGO{1,10};
  fclose(g);
%Cargamos los datos de AZPILICUETA:
  datosAZ=load([stn,'0',ddd,'x.15t']);
% definimos las variables de azpilicueta
  prnAZ=datosAZ(:,1);
  UT=datosAZ(:,4);
  UT(:,1)=UT(:,1).*3600;% Tiempo universal (epcoa) a segundos
  UT=round(UT); %Redondee a enteros  
  datosAZ(:,4)=UT(:,1);  %Lo introduzco en mi matriz de datos
  lat=datosAZ(:,6);
  lon=datosAZ(:,8);
  aci=datosAZ(:,9);
  eleAZ=datosAZ(:,10);
  sTECAZ=datosAZ(:,11);
  veqAZ=datosAZ(:,12);
% Cargamos los datos de Gigi       
  hh=fopen([stn,'F3_0',ddd,'.15A']);
  d_Gigi=textscan(hh,'%f %s %f %f %f %f %f %f');
% Definimos las variables de Gigi
  epoca_Gigi=d_Gigi{1,1};
  sate_Gigi=d_Gigi{1,2};
  azi_Gigi=d_Gigi{1,3};
  ele_Gigi=d_Gigi{1,4};
  lon_Gigi=d_Gigi{1,5};
  lat_Gigi=d_Gigi{1,6};
  sTEC_Gigi=d_Gigi{1,7};
  veq_Gigi=d_Gigi{1,8};
  fclose(hh);

  %Matrices de STEC por epoca y satelite.  elevacion>20
%Azpilicueta
D_Az=zeros(1440,33);
   for t=0:60:max(UT)
       n=n+1;
       for s=1:length(UT)
             if datosAZ(s,4)==t  && datosAZ(s,10)>20
              nsat=datosAZ(s,1);
              D_Az(n,nsat+1)=datosAZ(s,11);
             end
       end
   end
clear t s h

%Gopi
D_gopi=zeros(1440,33);
  for i=0:60:max(ep(:,1))
      N=N+1;
    for q=1:length(ep)
      if ep(q,1)==i &&  eleGoppi(q,1)>20 
         numsat=prnGopi(q,1);
         D_gopi(N,numsat+1)=sTECGO(q,1);  
     end
   end
  end
clear i q 

% Gigi trabaja con GLONASS-> seleccionamos solo GPS
n=0;
for i=1:length(epoca_Gigi)  %% Tenemos diferentes satelites
    n=n+1;
    a=sate_Gigi(i,1);
    b=cell2mat(a);
    L=b(1);
    Ns=b(2:3);
    if strcmp(L,'R')==1 %Verdadero
        K=str2num(Ns);
        K=K+35; %Distinguimos los satelites rusos como los >35
    elseif strcmp(L,'R')==0  %Falso
    K=str2num(Ns);
    end
    nsate_Gigi(n,1)=K;
end
clear a b L Ns K i  nsate azi ele lon lat sTEC 

% Matriz de datos de Gigi
n=0;
Datos_Gigi=zeros(1440,33);
for i=0:60:max(epoca_Gigi(:,1))
    n=n+1;
    for q=1:length(epoca_Gigi(:,1))
        if epoca_Gigi(q,1)==i && nsate_Gigi(q,1)<35 && ele_Gigi(q,1)>20 %limitamos los satelites a GPS
            prn=nsate_Gigi(q,1);
            Datos_Gigi(n,prn+1)=sTEC_Gigi(q,1); %Matrix D-> epoca + sTEC de cada satelite
         elseif epoca_Gigi(q,1)>i
               break
        end
    end
end
clear  i q prn

% Matrices sTEC filtradas por elevacion > 45
%Gigi
n=0; c_datos_gigi=0;
for i=1:length(epoca_Gigi)  %% Tenemos diferentes satelites
    n=n+1;
    a=sate_Gigi(i,1);
    b=cell2mat(a);
    L=b(1);
    Ns=b(2:3);
    if strcmp(L,'R')==1 %Verdadero
        K=str2num(Ns);
        K=K+35; %Distinguimos los satelites rusos como los >35
    elseif strcmp(L,'R')==0  %Falso
    K=str2num(Ns);
    end
    nsate_Gigi(n,1)=K;
end
clear a b L Ns K i  nsate azi ele lon lat sTEC 
n=0;
Datos_Gigi_filtrados=zeros(1440,33);
for i=0:60:max(epoca_Gigi(:,1))
    n=n+1;
    for q=1:length(epoca_Gigi(:,1))
        if epoca_Gigi(q,1)==i && nsate_Gigi(q,1)<35 && ele_Gigi(q,1)>45 %limitamos los satelites a GPS
            prn=nsate_Gigi(q,1);
            Datos_Gigi_filtrados(n,prn+1)=sTEC_Gigi(q,1); %Matrix D-> epoca + sTEC de cada satelite
         elseif epoca_Gigi(q,1)>i
               break
        end
    end
end
clear  i q prn
%Azpi
Datos_Azpi_filtrados=zeros(1440,33);
n=0; c_datos_azpi=0;
for t=0:60:max(UT)
       n=n+1;
       for s=1:length(UT)
             if datosAZ(s,4)==t  && datosAZ(s,10)>45
              nsat=datosAZ(s,1);
              Datos_Azpi_filtrados(n,nsat+1)=datosAZ(s,11);
             end
       end
   end
clear t s h
%Gopi
Datos_Gopi_filtrados=zeros(1440,33);
N=0; c_datos_gopi=0;
for i=0:60:max(ep(:,1))
      N=N+1;
    for q=1:length(ep)
      if ep(q,1)==i &&  eleGoppi(q,1)>45 
         numsat=prnGopi(q,1);
          Datos_Gopi_filtrados(N,numsat+1)=sTECGO(q,1);  
     end
   end
  end
clear i q 
 
%Conteo de huecos/ceros
%elevacion>20
huecos_gigi1=0; huecos_gopi1=0; huecos_az1=0;
for j=2:33
    for i=1:size((Datos_Gigi),1)
        if Datos_Gigi(i,j)==0 && D_gopi(i,j)~=0 && D_Az(i,j)~=0
            huecos_gigi1=huecos_gigi1+1;
        elseif Datos_Gigi(i,j)==0 && D_gopi(i,j)==0 && D_Az(i,j)~=0
            huecos_gigi1=huecos_gigi1+1;
        elseif Datos_Gigi(i,j)==0 && D_gopi(i,j)~=0 && D_Az(i,j)==0
            huecos_gigi1=huecos_gigi1+1;
        end
    end
end
for j=2:33
    for i=1:size((Datos_Gigi),1)
        if Datos_Gigi(i,j)~=0 && D_gopi(i,j)==0 && D_Az(i,j)~=0
            huecos_gopi1=huecos_gopi1+1;
            elseif Datos_Gigi(i,j)==0 && D_gopi(i,j)==0 && D_Az(i,j)~=0
            huecos_gopi1=huecos_gopi1+1;
            elseif Datos_Gigi(i,j)~=0 && D_gopi(i,j)==0 && D_Az(i,j)==0
            huecos_gopi1=huecos_gopi1+1;
        end
    end
end
for j=2:33
    for i=1:size((Datos_Gigi),1)          
        if Datos_Gigi(i,j)~=0 && D_gopi(i,j)~=0 && D_Az(i,j)==0
            huecos_az1=huecos_az1+1;
        elseif Datos_Gigi(i,j)==0 && D_gopi(i,j)~=0 && D_Az(i,j)==0
            huecos_az1=huecos_az1+1;
        elseif Datos_Gigi(i,j)~=0 && D_gopi(i,j)==0 && D_Az(i,j)==0
            huecos_az1=huecos_az1+1;
        end
    end
end
%para elevacion>45
huecos_gigi2=0; huecos_gopi2=0; huecos_az2=0;
for j=2:33
    for i=1:size((Datos_Gigi),1)
        if Datos_Gigi_filtrados(i,j)==0 && Datos_Gopi_filtrados(i,j)~=0 && Datos_Azpi_filtrados(i,j)~=0
            huecos_gigi2=huecos_gigi2+1;
        elseif Datos_Gigi_filtrados(i,j)==0 && Datos_Gopi_filtrados(i,j)==0 && Datos_Azpi_filtrados(i,j)~=0
            huecos_gigi2=huecos_gigi2+1;
        elseif Datos_Gigi_filtrados(i,j)==0 && Datos_Gopi_filtrados(i,j)~=0 && Datos_Azpi_filtrados(i,j)==0
            huecos_gigi2=huecos_gigi2+1;
        end
    end
end
for j=2:33
    for i=1:size((Datos_Gigi),1)   
        if Datos_Gigi_filtrados(i,j)~=0 && Datos_Gopi_filtrados(i,j)==0 && Datos_Azpi_filtrados(i,j)~=0
            huecos_gopi2=huecos_gopi2+1;
            elseif Datos_Gigi_filtrados(i,j)==0 && Datos_Gopi_filtrados(i,j)==0 && Datos_Azpi_filtrados(i,j)~=0
            huecos_gopi2=huecos_gopi2+1;
            elseif Datos_Gigi_filtrados(i,j)~=0 && Datos_Gopi_filtrados(i,j)==0 && Datos_Azpi_filtrados(i,j)==0
            huecos_gopi2=huecos_gopi2+1;
        end
    end
end
for j=2:33
    for i=1:size((Datos_Gigi),1)
        if Datos_Gigi_filtrados(i,j)~=0 && Datos_Gopi_filtrados(i,j)~=0 && Datos_Azpi_filtrados(i,j)==0
            huecos_az2=huecos_az2+1;
        elseif Datos_Gigi_filtrados(i,j)==0 && Datos_Gopi_filtrados(i,j)~=0 && Datos_Azpi_filtrados(i,j)==0
            huecos_az2=huecos_az2+1;
        elseif Datos_Gigi_filtrados(i,j)~=0 && Datos_Gopi_filtrados(i,j)==0 && Datos_Azpi_filtrados(i,j)==0
            huecos_az2=huecos_az2+1;
        end
    end
end
%Eliminamos ceros
cantidad_datos_gigi=0; cantidad_datos_gopi=0; cantidad_datos_azpi=0;
cantidad_TEC_neg_gigi=0; cantidad_TEC_neg_gopi=0;cantidad_TEC_neg_azpi=0;
% Azpilicueta
  for i=2:size(D_Az,2)  
      for s=1:length(D_Az(:,1))
          if D_Az(s,i)==0 
             D_Az(s,i)=NaN;
             cantidad_datos_azpi=cantidad_datos_azpi+1;
          elseif D_Az(s,i)<0
              D_Az(s,i)=NaN;
              cantidad_TEC_neg_azpi=cantidad_TEC_neg_azpi +1;
              cantidad_datos_azpi=cantidad_datos_azpi+1;
            end
       end
  end
cantidad_TEC_neg_azpi=round(cantidad_TEC_neg_azpi/33);
 % Gopi
 ROT_Gopi(:,33)=0;
for j=2:size(D_gopi,2)
    for s=1:N 
        if D_gopi(s,j)==0
            D_gopi(s,j)=NaN;
            cantidad_datos_gopi=cantidad_datos_gopi+1;
        elseif D_gopi(s,j)<0
             cantidad_TEC_neg_gopi=cantidad_TEC_neg_gopi +1;
             D_gopi(s,j)=NaN;
             cantidad_datos_gopi=cantidad_datos_gopi+1;
        end
    end
end
clear j s
cantidad_TEC_neg_gopi=round(cantidad_TEC_neg_gopi/33);
%Gigi
for j=2:33 %Para cada satelite
        for s=1:length(Datos_Gigi(:,1))
        if Datos_Gigi(s,j)==0
            Datos_Gigi(s,j)=NaN;
            cantidad_datos_gigi=cantidad_datos_gigi+1;
        elseif Datos_Gigi(s,j)<0
             cantidad_TEC_neg_gigi=cantidad_TEC_neg_gigi +1;
             Datos_Gigi(s,j)=NaN;
             cantidad_datos_gigi=cantidad_datos_gigi+1;
        end
        end
end
cantidad_TEC_neg_gigi=round(cantidad_TEC_neg_gigi/33);
%Elevacion > 45
%Gigi
c_TEC_neg_gigi=0; 
for j=2:33
    for s=1:length(Datos_Gigi(:,1)) 
        if Datos_Gigi_filtrados(s,j)==0 
            Datos_Gigi_filtrados(s,j)=NaN;
            c_datos_gigi=c_datos_gigi+1;
        elseif Datos_Gigi_filtrados(s,j)<0
            c_TEC_neg_gigi=c_TEC_neg_gigi +1;
            Datos_Gigi_filtrados(s,j)=NaN;
            c_datos_gigi=c_datos_gigi+1;
        end
    end
end
c_TEC_neg_gigi=round(c_TEC_neg_gigi/33);
%Azpi
c_TEC_neg_azpi=0; dato_erroneo_azpi2=0; dato_erroneo_gigi2=0;
for j=2:33
    for s=1:length(Datos_Gigi(:,1))
        if Datos_Azpi_filtrados(s,j)==0 
            Datos_Azpi_filtrados(s,j)=NaN;
            c_datos_azpi=c_datos_azpi+1;
        elseif Datos_Azpi_filtrados(s,j)<0
              Datos_Azpi_filtrados(s,j)=NaN;
              c_TEC_neg_azpi=c_TEC_neg_azpi+1;
              c_datos_azpi=c_datos_azpi+1;
       end
    end
end
c_TEC_neg_azpi=round(c_TEC_neg_azpi/33);
%Gopi
c_TEC_neg_gopi=0; dato_erroneo_gopi2=0;
for j=2:33
    for s=1:length(Datos_Gigi(:,1))
        if Datos_Gopi_filtrados(s,j)==0 
            Datos_Gopi_filtrados(s,j)=NaN;
            c_datos_gopi=c_datos_gopi+1;
        elseif Datos_Gopi_filtrados(s,j)<0
               c_datos_gopi=c_datos_gopi+1;
               Datos_Gopi_filtrados(s,j)=NaN;
               c_TEC_neg_gopi=c_TEC_neg_gopi+1;
        end
    end
end
c_TEC_neg_gopi=round(c_TEC_neg_gopi/33);

%Cantidad de datos
%Elevacion > 20
cantidad_datos_gigi=1440-(cantidad_datos_gigi/33);
cantidad_datos_gopi=1440-(cantidad_datos_gopi/33);
cantidad_datos_azpi=1440-(cantidad_datos_azpi/33);
%Elevacion > 45
c_datos_gigi=1440-(c_datos_gigi/33);
c_datos_gopi=1440-(c_datos_gopi/33);
c_datos_azpi=1440-(c_datos_azpi/33);

%Matriz de diferencias, bias y std
%Elevacion>20
Diferencias_Gigi_Az=abs(Datos_Gigi-D_Az);
bias1=nanmean(nanmean(Diferencias_Gigi_Az));
Std1=sqrt(nanmean((nanmean(Diferencias_Gigi_Az)-bias1).^2));

Diferencias_Gigi_Gopi=abs(Datos_Gigi-D_gopi);
bias2=nanmean(nanmean(Diferencias_Gigi_Gopi));
Std2=sqrt(nanmean((nanmean(Diferencias_Gigi_Gopi)-bias2).^2));


Diferencias_Azpi_Gopi=abs(D_Az-D_gopi);
bias3=nanmean(nanmean(Diferencias_Azpi_Gopi));
Std3=sqrt(nanmean((nanmean(Diferencias_Azpi_Gopi)-bias3).^2));

%Elevacion > 45
Dif_ELEV_Gigi_Az=abs(Datos_Gigi_filtrados-Datos_Azpi_filtrados);
biasELEV_Gigi_Azpi=nanmean(nanmean(Dif_ELEV_Gigi_Az));
Std_ELEV_Gigi_Azpi=sqrt(nanmean((nanmean(Dif_ELEV_Gigi_Az)-biasELEV_Gigi_Azpi).^2));

Dif_ELEV_Gigi_Gopi=abs(Datos_Gigi_filtrados-Datos_Gopi_filtrados);
biasELEV_Gigi_Gopi=nanmean(nanmean(Dif_ELEV_Gigi_Gopi));
Std_ELEV_Gigi_Gopi=sqrt(nanmean((nanmean(Dif_ELEV_Gigi_Gopi)-biasELEV_Gigi_Gopi).^2));

Dif_ELEV_Azpi_Gopi=abs(Datos_Azpi_filtrados-Datos_Gopi_filtrados);
biasELEV_Azpi_Gopi=nanmean(nanmean(Dif_ELEV_Azpi_Gopi));
Std_ELEV_Azpi_Gopi=sqrt(nanmean((nanmean(Dif_ELEV_Azpi_Gopi)-biasELEV_Azpi_Gopi).^2));

%Matrices de resultados
HUECOS((k-68),1)=round(huecos_gigi1,0);
HUECOS((k-68),2)=round(huecos_gopi1,0);
HUECOS((k-68),3)=round(huecos_az1,0);
HUECOS((k-68),4)=round(huecos_gigi2,0);
HUECOS((k-68),5)=round(huecos_gopi2,0);
HUECOS((k-68),6)=round(huecos_az2,0);
HUECOS((k-68),7)=round(cantidad_datos_gigi,0);
HUECOS((k-68),8)=round(cantidad_datos_gopi,0);
HUECOS((k-68),9)=round(cantidad_datos_azpi,0);
HUECOS((k-68),10)=round(c_datos_gigi,0);
HUECOS((k-68),11)=round(c_datos_gopi,0);
HUECOS((k-68),12)=round(c_datos_azpi,0);
HUECOS((k-68),13)=cantidad_TEC_neg_gigi;
HUECOS((k-68),14)=cantidad_TEC_neg_gopi;
HUECOS((k-68),15)=cantidad_TEC_neg_azpi;
HUECOS((k-68),16)=c_TEC_neg_gigi;
HUECOS((k-68),17)=c_TEC_neg_gopi;
HUECOS((k-68),18)=c_TEC_neg_azpi;
HUECOS((k-68),19)=0;
HUECOS((k-68),20)=0;
HUECOS((k-68),21)=0;
HUECOS((k-68),22)=dato_erroneo_gigi2;
HUECOS((k-68),23)=dato_erroneo_gopi2;
HUECOS((k-68),24)=dato_erroneo_azpi2;

RESULTADOS((k-68),1)=round(bias1,3); RESULTADOS((k-68),2)=round(Std1,3);
RESULTADOS((k-68),3)=round(bias2,3); RESULTADOS((k-68),4)=round(Std2,3);
RESULTADOS((k-68),5)=round(bias3,3); RESULTADOS((k-68),6)=round(Std3,3);
RESULTADOS((k-68),7)=NaN;
RESULTADOS((k-68),8)=round(biasELEV_Gigi_Azpi,3); RESULTADOS((k-68),9)=round(Std_ELEV_Gigi_Azpi,3);
RESULTADOS((k-68),10)=round(biasELEV_Gigi_Gopi,3); RESULTADOS((k-68),11)=round(Std_ELEV_Gigi_Gopi,3);
RESULTADOS((k-68),12)=round(biasELEV_Azpi_Gopi,3); RESULTADOS((k-68),13)=round(Std_ELEV_Azpi_Gopi,3);
RESULTADOS((k-68),14)=filtro; RESULTADOS((k-68),15)=filtro2;
%Representaciones

%sTEC diario elevacion >20
figure(k);
for p=2:33;
t=0:30:(1440*30-30);
w=0:3750:4.5*10^4-3750;
plot(t,Datos_Gigi(:,p),'MarkerSize',3,'Marker','.','LineStyle','none','Color',[0 0 1]);
hold on;
plot(t,D_gopi(:,p),'MarkerSize',3,'Marker','.','LineStyle','none','Color',[1 0 0]);
plot(t,D_Az(:,p),'MarkerSize',3,'Marker','.','LineStyle','none','Color',[0 1 0]);
title(['Dia',di,', Estación de Torino (Italia)']);
set(gca,'XTick',w,'XTickLabel',{'0','2','4','6','8','10','12','14','16','18','20','22'},'FontSize',20);%,'DisplayName','Gigi','Color',[1 0 0],'Gopi','Color',[0 0 1],'Azpilicueta', [0 1 0]);
legend('Prf. Ciraolo','Dr.Gopi K.Seemala ','Dr.Francisco Azpilicueta');
axis([0 4.5*10^4 0 250]);
xlabel('UT'), ylabel('sTEC (TECu)');
print(figure(k),'-djpeg',['ejemplo_sTEC dia',di,'.jpg']);
hgsave(figure(k),['ejemplo_sTEC dia',di,' ']);
end

clear Diferencias_Gigi_Gopi Datos_Gigi D_gopi Diferencias_Gigi_Az D_Az Datos_Gigi_filtrados Datos_Gopi_filtrados Datos_Azpi_filtrados
end



