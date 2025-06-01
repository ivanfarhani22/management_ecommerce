<?php

namespace App\Services;

use GuzzleHttp\Client;
use Illuminate\Support\Facades\Log;
use GuzzleHttp\Exception\RequestException;
use GuzzleHttp\Exception\ConnectException;
use GuzzleHttp\RequestOptions;

class ChatbotService
{
    protected Client $client;
    protected string $pythonApiBaseUrl;
    protected string $pythonChatApiEndpoint;

    public function __construct()
    {
        // Pastikan URL dan port sesuai dengan server Python Anda
        $this->pythonApiBaseUrl = rtrim(env('PYTHON_CHATBOT_URL', 'http://127.0.0.1:8000'), '/');
        $this->pythonChatApiEndpoint = '/chat'; // Endpoint di API Python

        $this->client = new Client([
            'base_uri' => $this->pythonApiBaseUrl,
            RequestOptions::TIMEOUT  => 30.0, // Timeout permintaan keseluruhan
            RequestOptions::CONNECT_TIMEOUT => 10.0, // Timeout koneksi
            RequestOptions::HEADERS => [
                'Accept' => 'application/json',
                'Content-Type' => 'application/json',
            ],
            RequestOptions::HTTP_ERRORS => true, // Agar Guzzle melempar exception untuk status 4xx/5xx
        ]);
    }

    /**
     * Mengirim pesan ke API Python RAG Chatbot dan mendapatkan respons.
     *
     * @param string $message Pesan dari pengguna.
     * @param int|null $userId ID pengguna (opsional).
     * @return array Respons untuk frontend.
     */
    public function processMessage(string $message, ?int $userId): array
    {
        // Payload yang dikirim ke API Python
        // Sesuaikan dengan ChatRequest Pydantic model di Python (message, customer_id)
        $payload = [
            'message' => $message,
            'customer_id' => $userId
        ];
        $fullUrl = $this->pythonApiBaseUrl . $this->pythonChatApiEndpoint;

        try {
            Log::info("ChatbotService: Mengirim pesan ke Python API.", [
                'full_url_target' => $fullUrl,
                'payload' => $payload
            ]);

            // Mengirim permintaan POST ke endpoint /chat di API Python
            $response = $this->client->post($this->pythonChatApiEndpoint, [
                RequestOptions::JSON => $payload
            ]);

            $statusCode = $response->getStatusCode();
            $body = $response->getBody()->getContents();

            Log::debug("ChatbotService: Menerima respons dari Python API.", [
                'status_code' => $statusCode,
                'raw_body' => $body
            ]);

            if ($statusCode === 200) {
                $data = json_decode($body, true);

                if (json_last_error() === JSON_ERROR_NONE) {
                    // API Python mengembalikan {"response": "..."}
                    // Pastikan ini sesuai dengan ChatResponse Pydantic model di Python
                    if (isset($data['response'])) { // Mencari kunci 'response'
                        Log::info("ChatbotService: Respons sukses dan valid dari Python API.", [
                            'parsed_data' => $data
                        ]);
                        return [
                            'type' => 'text',
                            'content' => $data['response'] // Menggunakan nilai dari kunci 'response'
                        ];
                    } else {
                        Log::error("ChatbotService: Respons JSON valid dari Python API, tetapi key 'response' tidak ditemukan.", [
                            'parsed_data' => $data
                        ]);
                        return $this->createErrorResponse("Format respons dari layanan chatbot tidak sesuai (key 'response' hilang).");
                    }
                } else {
                    Log::error("ChatbotService: Gagal mendekode JSON dari Python API meskipun status 200.", [
                        'json_error' => json_last_error_msg(),
                        'raw_body_on_json_error' => $body
                    ]);
                    return $this->createErrorResponse('Maaf, ada masalah saat memproses format respons dari layanan chatbot.');
                }
            } else {
                // Seharusnya tidak sampai sini jika RequestOptions::HTTP_ERRORS => true,
                // karena Guzzle akan melempar exception untuk status 4xx/5xx
                Log::error("ChatbotService: Menerima status code tak terduga (bukan 200) dari Python API.", [
                    'status_code' => $statusCode,
                    'response_body' => $body
                ]);
                return $this->createErrorResponse('Layanan chatbot mengembalikan status yang tidak diharapkan.');
            }

        } catch (ConnectException $e) {
            Log::critical('ChatbotService: Kesalahan koneksi ke Python API.', [
                'target_url' => $fullUrl, 'error_message' => $e->getMessage()
            ]);
            return $this->createErrorResponse('Tidak dapat terhubung ke layanan chatbot. Pastikan layanan backend Python aktif dan dapat dijangkau.');
        } catch (RequestException $e) {
            $responseBody = $e->hasResponse() ? $e->getResponse()->getBody()->getContents() : 'Tidak ada body respons.';
            $statusCode = $e->hasResponse() ? $e->getResponse()->getStatusCode() : null;

            Log::error('ChatbotService: Kesalahan permintaan ke API Python.', [
                'target_url' => $fullUrl, 'status_code' => $statusCode, 'response_body' => $responseBody, 'error_message' => $e->getMessage()
            ]);
            
            $errorDetail = 'Terjadi kesalahan pada layanan chatbot.';
            if ($statusCode === 404) {
                $errorDetail = 'Layanan chatbot tidak ditemukan pada alamat (' . $fullUrl . '). Periksa konfigurasi endpoint API Python.';
            } elseif ($e->hasResponse()) {
                $errorData = json_decode($responseBody, true);
                // FastAPI biasanya mengembalikan error dalam format {"detail": "pesan error"}
                if (is_array($errorData) && isset($errorData['detail'])) {
                   $errorDetail = is_string($errorData['detail']) ? $errorData['detail'] : 'Kesalahan tidak spesifik dari layanan chatbot.';
                } elseif (is_array($errorData) && isset($errorData['error'])) { // Fallback jika format lain
                   $errorDetail = "Layanan chatbot Python error: " . $errorData['error'];
                } elseif (is_array($errorData) && isset($errorData['message'])) { // Fallback lain
                    $errorDetail = $errorData['message'];
                }
            }
            return $this->createErrorResponse($errorDetail);
            
        } catch (\Exception $e) { // Menangkap exception umum lainnya
            Log::error('ChatbotService: Kesalahan Umum Tidak Terduga.', [
                'target_url' => $fullUrl, 'error_message' => $e->getMessage(), 'trace' => $e->getTraceAsString()
            ]);
            return $this->createErrorResponse('Terjadi kesalahan tak terduga pada sistem kami. Silakan coba lagi nanti.');
        }
    }

    // Metode placeholder, implementasikan sesuai kebutuhan
    public function getChatHistory(int $userId): array
    {
        Log::info("ChatbotService: getChatHistory dipanggil untuk user_id: $userId (Belum diimplementasikan)");
        return [['type' => 'info', 'content' => "Fitur riwayat obrolan belum tersedia."]];
    }

    public function clearChatHistory(int $userId): void
    {
        Log::info("ChatbotService: clearChatHistory dipanggil untuk user_id: $userId (Belum diimplementasikan)");
    }

    private function createErrorResponse(string $message): array
    {
        return ['type' => 'error', 'content' => $message];
    }
}