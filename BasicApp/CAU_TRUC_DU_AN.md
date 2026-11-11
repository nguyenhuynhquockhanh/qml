# Cau truc du an cluster

`main.cpp` khoi tao Qt, ket noi model voi QML va nap giao dien. `main.qml`
giu cua so 1024x600, ti le hien thi va cac gia tri dua vao giao dien.

| Thu muc/file | Chuc nang |
| --- | --- |
| `ma_nguon/cau_hinh_do_hoa.*` | EGLFS KMS, OpenGL ES, render loop va DPI. Goi truoc khi tao `QGuiApplication`. |
| `ma_nguon/nha_cung_cap_anh.*` | Doc anh da cai tai `bin/images` tren Pi, chuyen sang premultiplied truoc khi dua vao Qt Quick. |
| `ma_nguon/nguon_du_lieu_can.*` | SocketCAN `can0`, filter ID, nhan frame bang `QSocketNotifier`, ket noi lai va timeout tung nhom du lieu. Khong co thread nhan CAN. |
| `ma_nguon/giai_ma_can.*` | Giai ma phanh `0x020`, sonar `0x030` va RPM `0x080`. |
| `ma_nguon/du_lieu_cum_dong_ho.*` | Gia tri va tin hieu thay doi cho QML. |
| `qml/Giao_dien_cum_dong_ho.qml` | Ghep cac lop giao dien theo thu tu `z`. |
| `qml/Cum_hai_dong_ho.qml`, `qml/Dong_ho.qml` | Vi tri hai dong ho va ve mat dong ho dung chung. |
| `qml/Nen_cum_dong_ho.qml`, `qml/Vien_cum_dong_ho.qml` | Nen va khung ngoai. |
| `qml/Canh_duong.qml`, `qml/Xe_trung_bay.qml` | Duong phoi canh va anh xe. |
| `qml/Thong_tin_phia_tren.qml`, `qml/Thong_tin_hanh_trinh.qml` | Gio, ngay, nhiet do, che do lai, quang duong va ODO. |
| `qml/Den_tin_hieu.qml`, `qml/Xi_nhan.qml`, `qml/Canh_bao_nhap_nhay.qml`, `qml/Cum_bieu_tuong_canh_bao.qml` | Xi nhan, diem mu va cac icon canh bao. |
| `images/`, `fonts/` | Tai nguyen dang su dung; `images.qrc` phuc vu QML ngoai Pi, anh tren Pi duoc cai thanh file rieng. |

`qmlscene main.qml` dung anh tu `images/` tren may phat trien. Ban Pi dung
`image://dashboard/` va thu muc `/home/ras/BasicApp/bin/images` de giu cach nap
anh da on dinh. Danh sach QML trong `qml.qrc` giu cung cau truc duong dan voi
file tren dia. `BasicApp.pro` khai bao cac file C++ va anh can cai len Pi.

Giao thuc CAN va cach cau hinh `can0` duoc mo ta trong `CAN_INPUT.md`.
