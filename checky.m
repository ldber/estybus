% This script checks the inferred Ybus against the actual Ybus.

load Ytrue.mat;

Gerror = abs(real(Yinfer) - real(Ytrue));
Berror = abs(imag(Yinfer) - imag(Ytrue));

figure;
subplot(2,2,1);
heatmap(Gerror);
title('G error (p.u.)')
subplot(2,2,2);
heatmap(Berror);
title('B error (p.u.)')
subplot(2,2,3);
heatmap(real(Ytrue));
title('Gbus (p.u.)')
subplot(2,2,4);
heatmap(imag(Ytrue));
title('Bbus (p.u.)')