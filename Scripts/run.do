vlib work
vlog ../RTL/*.v   ../testbenches/*.v
vsim work.tb_top_system_250k
add wave *
run -all


#vsim -do ../script/run.do

#% 1. إدخال بيانات اختبارية (2 بايت payload)
#incomingStream = [1 0 1 0 1 0 1 0  1 1 0 0 1 1 0 0];
#dataRate = 0; % 0 تعني معدل 1Mbps
#chirpSequence = ones(1, 4);

#% 2. استدعاء الدالة لتوليد الملفات الخمسة تلقائياً
#TxchirpSequences = ChirpSpreadSpectrum_Tx(incomingStream, dataRate, chirpSequence);
