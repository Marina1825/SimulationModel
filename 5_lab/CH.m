import org.zeromq.ZMQ;
import org.zeromq.ZMQ.Context;
import org.zeromq.ZMQ.Socket;

public class CostHataCalculator {

    public static void main(String[] args) {
        int port_api = 2111;
        Context context = ZMQ.context(1);
        Socket socket_api_proxy = context.socket(ZMQ.REP);
        socket_api_proxy.bind("tcp://*:" + port_api);

        System.out.println("Start");

        while (true) {
            byte[] msg = socket_api_proxy.recv();
            if (msg != null && msg.length > 1000) {
                System.out.printf("Received message [%d]\n", msg.length);
                processData(msg);
                socket_api_proxy.send("OK");
            }
        }
    }

    private static void processData(byte[] dataRaw) {
        int fs = 23040000;
        System.out.printf("Size of data: %d\n", dataRaw.length);

        // Преобразуем данные в комплексные числа
        float[] floatArray = new float[dataRaw.length / 4];
        for (int i = 0; i < floatArray.length; i++) {
            floatArray[i] = Float.intBitsToFloat(
                    ((dataRaw[i * 4] & 0xFF) << 24) |
                    ((dataRaw[i * 4 + 1] & 0xFF) << 16) |
                    ((dataRaw[i * 4 + 2] & 0xFF) << 8) |
                    (dataRaw[i * 4 + 3] & 0xFF)
            );
        }

        // Предположим, что данные содержат информацию о расстоянии и высоте антенн
        double distance = floatArray[0]; // Расстояние в километрах
        double h_b = floatArray[1]; // Высота базовой станции в метрах
        double h_m = floatArray[2]; // Высота мобильной станции в метрах
        double frequency = floatArray[3]; // Частота в МГц

        // Расчет потерь по модели COST-Hata
        double loss = calculateCostHata(distance, h_b, h_m, frequency);
        System.out.printf("COST-Hata Path Loss: %.2f dB\n", loss);
    }

    private static double calculateCostHata(double d, double h_b, double h_m, double f) {
        double c_h = 0.8 + (1.1 * Math.log10(f) - 0.7) * h_m - 1.56 * Math.log10(f);
        double loss = 69.55 + 26.16 * Math.log10(f) - 13.82 * Math.log10(h_b) - c_h + (44.9 - 6.55 * Math.log10(h_b)) * Math.log10(d);
        return loss;
    }
}