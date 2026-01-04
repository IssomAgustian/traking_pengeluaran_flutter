# Aplikasi Pelacak Pengeluaran Flutter

Aplikasi pelacakan pengeluaran yang komprehensif dibangun dengan Flutter dan backend PHP. Aplikasi ini memungkinkan pengguna untuk mengelola pengeluaran mereka, melihat riwayat transaksi, dan membuat laporan.

## 📋 Daftar Isi
- [Fitur](#fitur)
- [Prasyarat](#prasyarat)
- [Pengaturan Otomatis (Direkomendasikan)](#pengaturan-otomatis-direkomendasikan)
- [Pengaturan Manual](#pengaturan-manual)
- [Menjalankan Aplikasi](#menjalankan-aplikasi)
- [Pemecahan Masalah](#pemecahan-masalah)
- [Struktur Proyek](#struktur-proyek)
- [Endpoint API](#endpoint-api)

## 🌟 Fitur

- Menambah, mengedit, dan menghapus transaksi pengeluaran
- Melihat riwayat transaksi dengan opsi filter
- Manajemen dan pelacakan anggaran
- Visualisasi data dengan grafik
- Pembuatan laporan PDF
- Backend API RESTful dengan PHP

## 🛠️ Prasyarat

Sebelum mengatur aplikasi, pastikan Anda memiliki perangkat lunak berikut terinstal di sistem Anda:

### Perangkat Lunak yang Dibutuhkan
- **Flutter SDK** (versi stabil terbaru)
- **PHP** (versi 7.4 atau lebih tinggi)
- **Git** (untuk kontrol versi)
- **Android Studio** atau **VS Code** (dengan ekstensi Flutter)
- **Android SDK** (untuk pengembangan Android)

### Persyaratan Sistem
- Windows 7 atau lebih tinggi (untuk dukungan file batch)
- Setidaknya 4GB RAM (8GB direkomendasikan)
- 2GB ruang disk kosong

## 🚀 Pengaturan Otomatis (Direkomendasikan)

Cara termudah untuk mengatur dan menjalankan aplikasi adalah menggunakan file batch yang disediakan.

### Opsi 1: Pengaturan dan Jalankan Lengkap
Jalankan pengaturan lengkap yang akan mengkonfigurasi aplikasi, memulai server backend, dan meluncurkan aplikasi Flutter:

1. Klik dua kali pada file `run_app_complete.bat`
2. Skrip akan secara otomatis:
   - Mendeteksi alamat IP lokal Anda
   - Memperbarui konfigurasi API dengan IP Anda
   - Membersihkan dan mendapatkan dependensi Flutter
   - Memulai server backend PHP
   - Meluncurkan aplikasi Flutter

### Opsi 2: Komponen Terpisah
Jika Anda lebih suka menjalankan komponen secara terpisah:

1. **Mulai Server Backend Saja:**
   - Klik dua kali pada `run_backend_server.bat`
   - Server akan dimulai pada alamat IP lokal Anda di port 8000

2. **Jalankan Aplikasi Flutter Saja:**
   - Pastikan server backend sedang berjalan
   - Klik dua kali pada `run_flutter_app.bat`
   - Skrip akan memperbarui konfigurasi API dan meluncurkan aplikasi

## ⚙️ Pengaturan Manual

Jika Anda lebih suka mengatur aplikasi secara manual, ikuti langkah-langkah berikut:

### 1. Clone atau Unduh Repositori
```bash
git clone https://github.com/IssomAgustian/traking_pengeluaran_flutter.git
cd traking_pengeluaran_flutter
```

### 2. Instal Dependensi Flutter
```bash
flutter clean
flutter pub get
```

### 3. Siapkan Server Backend
1. Navigasi ke direktori `backend`
2. Pastikan PHP terinstal dan ada di PATH sistem Anda
3. Mulai server pengembangan PHP:
```bash
cd backend
php -S localhost:8000 -t .
```

### 4. Konfigurasi Endpoint API
Perbarui file layanan API dengan alamat IP lokal Anda:

1. Buka `lib/services/api_service.dart`
2. Perbarui variabel `baseUrl` dengan alamat IP lokal Anda:
```dart
final String baseUrl = "http://ALAMAT_IP_LOKAL_ANDA:8000";
```

3. Buka `lib/services/budget_api_service.dart`
4. Perbarui URL dasar dengan cara yang sama:
```dart
final String baseUrl = "http://ALAMAT_IP_LOKAL_ANDA:8000";
```

### 5. Jalankan Aplikasi Flutter
```bash
flutter run
```

## 📱 Menjalankan Aplikasi

### Menggunakan Emulator Android
1. Mulai emulator Android di Android Studio
2. Jalankan aplikasi:
```bash
flutter run
```

### Menggunakan Perangkat Fisik
1. Aktifkan debugging USB di perangkat Android Anda
2. Hubungkan perangkat melalui USB
3. Jalankan aplikasi:
```bash
flutter run
```

### Menggunakan Simulator iOS (jika berlaku)
1. Mulai simulator iOS
2. Jalankan aplikasi:
```bash
flutter run
```

## 🔧 Pemecahan Masalah

### Masalah Umum dan Solusi

#### Masalah: "Tidak dapat menyelesaikan host" atau "Koneksi gagal"
- **Solusi:** Pastikan server backend sedang berjalan dan dapat diakses
- Periksa bahwa alamat IP Anda dikonfigurasi dengan benar di file layanan API
- Pastikan firewall tidak memblokir koneksi

#### Masalah: "PHP tidak dikenali sebagai perintah internal atau eksternal"
- **Solusi:** Tambahkan PHP ke variabel lingkungan PATH sistem Anda
- Restart command prompt Anda setelah memperbarui PATH

#### Masalah: "Tidak ditemukan perangkat yang terhubung"
- **Solusi:** Pastikan emulator sedang berjalan atau perangkat fisik terhubung
- Periksa debugging USB diaktifkan pada perangkat Android

#### Masalah: "Port 8000 sudah digunakan"
- **Solusi:** Temukan dan hentikan proses yang menggunakan port 8000:
```bash
netstat -ano | findstr :8000
taskkill /PID <NOMOR_PID> /F
```

#### Masalah: "Build Gradle gagal"
- **Solusi:** Bersihkan dan buat ulang:
```bash
flutter clean
flutter pub get
flutter run
```

### Masalah Server Backend
- Pastikan server backend berjalan sebelum memulai aplikasi Flutter
- Periksa `backend/server.log` untuk kesalahan server
- Pastikan ekstensi PHP yang diperlukan oleh aplikasi Anda terinstal

## 📁 Struktur Proyek

```
expense_tracker_flutter/
├── lib/                    # Kode sumber Flutter
│   ├── services/          # Layanan API
│   │   ├── api_service.dart
│   │   └── budget_api_service.dart
│   ├── models/            # Model data
│   │   └── transaction_model.dart
│   ├── screens/           # Layar UI
│   └── main.dart          # Titik masuk aplikasi
├── backend/               # Backend PHP
│   ├── start_server.php   # Skrip startup server
│   ├── config.php         # Konfigurasi database
│   ├── create.php         # Endpoint buat transaksi
│   ├── read.php           # Endpoint baca transaksi
│   ├── update.php         # Endpoint perbarui transaksi
│   ├── delete.php         # Endpoint hapus transaksi
│   ├── database_schema.sql # Skema database
│   └── budgets/           # Endpoint terkait anggaran
├── assets/                # Aset aplikasi
├── test/                  # File uji
├── run_app_complete.bat   # Skrip pengaturan dan jalankan lengkap
├── run_backend_server.bat # Skrip server backend saja
├── run_flutter_app.bat    # Skrip aplikasi Flutter saja
└── pubspec.yaml           # Dependensi Flutter
```

## 🌐 Endpoint API

Backend menyediakan endpoint API RESTful berikut:

| Metode | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/read.php` | Mendapatkan semua transaksi |
| POST | `/create.php` | Membuat transaksi baru |
| POST | `/update.php` | Memperbarui transaksi yang ada |
| POST | `/delete.php` | Menghapus transaksi |
| POST | `/budgets/create.php` | Membuat anggaran |
| GET | `/budgets/read.php` | Mendapatkan semua anggaran |

## 🤝 Kontribusi

1. Fork repositori
2. Buat branch fitur (`git checkout -b fitur/FituryangHebat`)
3. Commit perubahan Anda (`git commit -m 'Tambah Fitur Hebat'`)
4. Push ke branch (`git push origin fitur/FituryangHebat`)
5. Buka Pull Request

## 📄 Lisensi

Proyek ini dilisensikan di bawah Lisensi MIT - lihat file [LISENSI](LISENSI) untuk detailnya.

## 🆘 Dukungan

Jika Anda mengalami masalah atau memiliki pertanyaan, silakan:
1. Periksa bagian [Pemecahan Masalah](#pemecahan-masalah)
2. Buka isu di repositori GitHub
3. Hubungi tim pengembangan

---

Dibuat dengan ❤️ menggunakan Flutter dan PHP