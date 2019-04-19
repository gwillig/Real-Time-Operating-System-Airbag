%% Festplatte formatieren und Linux aufspielen:
clear; clc;

%% Parameter für die Simulation
Simulationsdauer = 20;
Crashzeitpunkt = -1; %Wann soll der Crash auftreten? -1: Kein Crash


%% Initalisierung der Tasks:
NOP=Klasse_Task;

T2=Klasse_Task;
T2.id = 2;
T2.Name='T2';
T2.Systemprioritaet=2;
T2.Periodendauer=0;
T2.Execution_Time=1;
T2.Abhaengigkeit="Ja";
T2.Status="waiting";
T2.Nachfolger = [];
T2.Zeitpunkt=0;
T2.Beschreibung="Gasgenerator und Airbag auslösen";

T1=Klasse_Task;
T1.Name='T1';
T1.id = 1;
T1.Systemprioritaet=1;
T1.Periodendauer=0;
T1.Execution_Time=1;
T1.Executed_Time=0;
T1.Abhaengigkeit="Ja";
T1.Status="waiting";
T1.Nachfolger=[T2];
T1.Zeitpunkt=0;
T1.Beschreibung="Gasgenerator  Gurtspanner auslösen",

T3=Klasse_Task;
T3.id = 3;
T3.Name='T3';
T3.Systemprioritaet=2;
T3.Periodendauer=0;
T3.Execution_Time=2;
T3.Abhaengigkeit="Ja";
T3.Status="waiting";
T3.Nachfolger=T1;
T3.Zeitpunkt=0;
T3.Beschreibung="Zeitpunkt und Zündstufe des  Airbags  und Gurtspanner ermitteln";

T7=Klasse_Task;
T7.id = 7;
T7.Name='T7';
T7.Systemprioritaet=3;
T7.Periodendauer=1000;
T7.Execution_Time=10;
T7.Abhaengigkeit=["Ja"];
T7.Status="ready";
T7.Zeitpunkt=0;
T7.Beschreibung="Diagnosefunktion";

T6=Klasse_Task;
T6.id = 6;
T6.Name='T6';
T6.Systemprioritaet=3;
T6.Periodendauer=10;
T6.Execution_Time=1;
T6.Abhaengigkeit=["Ja"];
T6.Nachfolger=[];
T6.Status="waiting";
T6.Zeitpunkt=0;
T6.Beschreibung="Sitzbelegung, Sitzposition bewerten";

T4=Klasse_Task;
T4.id = 4;
T4.Name='T4';
T4.Systemprioritaet=3;
T4.Periodendauer=5;
T4.Execution_Time=1;
T4.Abhaengigkeit=["Ja"];
T4.Nachfolger=[T6,T7,T3];
T4.Status="waiting";
T4.Zeitpunkt=0;
T4.Beschreibung="Auswertung der gemessenen Größen";

T5=Klasse_Task;
T5.id = 5;
T5.Name='T5';
T5.Systemprioritaet=3;
T5.Periodendauer=5;
T5.Execution_Time=1;
T5.Executed_Time=0;
T5.Abhaengigkeit=["Nein"];
T5.Nachfolger=[T4];
T5.Status="ready";
T5.Zeitpunkt=0;
T5.Beschreibung="Erfassung der Sensormesswerte";

%% Zusammenfassung aller Tasks in einer Liste
tasklist = [T1, T2, T3, T4, T5, T6, T7];

%% Initalisierung der Task-Warteschlange:
executequeue = []; %hier befinden sich alle Tasks, die ausgeführt werden sollen

%% Initalisierung der Prozessor-Klasse
P1 = Klasse_Prozessor; %Klasse stellt Prozessor symbolisch dar

%% Initalisierung des Zeitverktors und den logischen Flags:
t=0; %aktuelle Zeit in ms
timeline = [];
crash = 0; %Flag für Crash initialisieren und auf null setzen
messwerte.geschwindigkeit=50;
messwerte.gforce=0;

for z=1:Simulationsdauer

%% Scheduler
% Excecution-Schlange nach Tasks durchsuchen, die komplett abgearbeitet
% wurden -> Abgearbeitete Tasks werden entfernt.
for i = 1:length(executequeue)
    if(executequeue(i).Executed_Time>=executequeue(i).Execution_Time)
    %Wenn nachfolgende Tasks abhängig sind, werden diese nun auf 'ready'
    %gesetzt
    if(executequeue(i).Nachfolger~=0)
        for k=1:length(executequeue(i).Nachfolger) 
            executequeue(i).Nachfolger(k).Status="ready";
        end
    end
    %Executed Time zurücksetzen
    executequeue(i).Executed_Time = 0;
    
    %Fertigen Task aus Liste löschen
    executequeue(i)=[];
    end
    
    %%length(executequeue) ändert sich, da Tasks gelöscht werden 
    if (i==length(executequeue))
        break;
    end
end

%% Liste aller anstehenden Tasks erstellen bzw. Task-Warteschlange erstellen
    %Durch alle periodischen Tasks gehen und schauen, ob Periodendauer
    %abgelaufen ist -> Falls abgelaufen, muss des Task neu in die
    %Warteschlange aufgenommen werden
    for i = 1:length(tasklist)
        if (tasklist(i).Periodendauer ~= 0)
            if(mod(t,tasklist(i).Periodendauer) == 0)
              if(tasklist(i).Abhaengigkeit=="Ja")
                tasklist(i).Status = "waiting";
              end
              executequeue = [executequeue, tasklist(i)]; 
            end
        end
    end
%% Crashbedingungen abfragen
if (t==Crashzeitpunkt)
    crash = 1;
    for i = 1:length(tasklist)
    %Handelt es sich um einen aperiodischen Task?
        if (tasklist(i).Periodendauer == 0)
            tasklist(i).Status="waiting"
        end
    end
end
%% Aperiodische Tasks im Crashfall in executequeue einfügen    
 if (crash ==1)
     executequeue = [executequeue,T3,T1,T2];
     crash=0;
 end
 
%% Queue nach Prios durchsortieren
[~,ind] = sort([executequeue.Systemprioritaet]);
executequeue= executequeue(ind);

%% Queue zusätzlich nach periodendauer durchsortieren -> Tasks mit niedriger Periodendauer werden bevorzugt
for k = 1:length(executequeue)
    k=k+1;
    for i = 1:length(executequeue)-1
        if ((executequeue(i).Systemprioritaet == executequeue(i+1).Systemprioritaet) &&(executequeue(i).Periodendauer>executequeue(i+1).Periodendauer) )
        %%Systemprios sind gleich, aber Periodendauer ist größer als beim
        %%Nachfolgenden Task -> Reihenfolge tauschen
        temp = executequeue(i+1);
        executequeue(i+1) = executequeue(i);
        executequeue(i) = temp;
        end
    end
end


%% Ersten Tasks einlasten, der Status "ready" besitzt (nach Reihenfolge in executionqueue) und in Matrix-Form dokumentieren
for i = 1:length(executequeue)
    if(executequeue(i).Status =="ready")
        executequeue(i).Executed_Time =executequeue(i).Executed_Time+1;
        P1.ExcecutingTask=executequeue(i) %Task auf Prozessor legen
        break;  
    end
end
%% Zeit aktualisieren
t=t+1;

%Wenn Execution-Schlange leer, Prozessr "NOP" (No Operation Task) geben
if(isempty(executequeue))
    P1.ExcecutingTask = NOP
end

timeline = [timeline, P1.ExcecutingTask];

end

%% Ergebnis plotten
ZeichenMatrix=ones(7,length(timeline));
AktivitaetsMatrix=zeros(7,length(timeline));
TasksNamen=[1, 2, 3, 4, 5, 6, 7];

a=[1, 1, 1, 1, 1, 1, 1;
   1, 1, 1, 1, 1, 1, 1];
b=[1;2];

%% Binäre Matrix der aktiven Tasks erstellen
for i=1:length(timeline);
    j=timeline(i).id;
    AktivitaetsMatrix(j,i)=i;    
end

figure(1);
imagesc(AktivitaetsMatrix(1:7,:));
xticks([]);
ylabel('Tasknummer');
xlabel('Zeit');
title('Scheduling-Ergebnis');

cmap=zeros(length(timeline),3);
r = linspace(1,0,length(timeline));
g = linspace(0,1,length(timeline));
b = linspace(0,0,length(timeline));
cmap(1,:)=[1,1,1];
for i=2:length(timeline);
    cmap(i,:)=[r(i), g(i), b(i)];
end

colormap(cmap);








