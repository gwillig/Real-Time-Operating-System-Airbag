classdef Klasse_Task < handle
   properties
      Systemprioritaet
      Periodendauer =0
      Execution_Time =0
      Executed_Time =0
      Abhaengigkeit
      Nachfolger
      Zeitpunkt
      Status = ""
      Name
      id
      Beschreibung
   end
   methods
      function r = roundOff(obj)
         r = round([obj.Value],2);
      end

   end
end


