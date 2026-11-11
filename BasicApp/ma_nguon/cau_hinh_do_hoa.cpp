#include "cau_hinh_do_hoa.h"

#include <QByteArray>
#include <QCoreApplication>
#include <QQuickWindow>
#include <QSGRendererInterface>
#include <QSurfaceFormat>

bool cauHinhDoHoa(int argc, char *argv[])
{
    bool eglfs = qgetenv("QT_QPA_PLATFORM").startsWith("eglfs");
    for (int i = 1; i + 1 < argc; ++i) {
        if (qstrcmp(argv[i], "-platform") == 0
                && QByteArray(argv[i + 1]).startsWith("eglfs")) {
            eglfs = true;
            break;
        }
    }

    // EGLFS KMS + OpenGL ES va render loop basic tren Raspberry Pi.
    if (eglfs) {
        qputenv("QT_QPA_EGLFS_INTEGRATION", "eglfs_kms");
        qputenv("QT_QPA_EGLFS_HIDECURSOR", "1");
        qputenv("QSG_RENDER_LOOP", "basic");
        QCoreApplication::setAttribute(Qt::AA_UseOpenGLES);

        QSurfaceFormat format;
        format.setRenderableType(QSurfaceFormat::OpenGLES);
        format.setVersion(2, 0);
        format.setSwapBehavior(QSurfaceFormat::DoubleBuffer);
        format.setSwapInterval(1);
        QSurfaceFormat::setDefaultFormat(format);
    }

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QQuickWindow::setSceneGraphBackend(QSGRendererInterface::OpenGL);
    return eglfs;
}
