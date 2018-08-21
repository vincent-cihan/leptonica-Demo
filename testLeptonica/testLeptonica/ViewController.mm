//
//  ViewController.m
//  testLeptonica
//
//  Created by 刘乙灏 on 2018/8/6.
//  Copyright © 2018年 刘乙灏. All rights reserved.
//

#import "ViewController.h"
#include "allheaders.h"



#define   DO_QUAD     1
#define   DO_CUBIC    0
#define   DO_QUARTIC  0

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self dewarpTest1];
}

-(NSString *)getImagePath:(UIImage *)Image{
    
    NSString * filePath = nil;
    
    //  NSData * imageData = UIImageJPEGRepresentation(Image,1);
    //  CGFloat length = [imageData length]/1000;
    //
    //  NSData *data = nil;
    //
    //  if (length > 1024) {
    //    data=UIImageJPEGRepresentation(Image, 0.1);
    //  } else if (length > 512) {
    //    data=UIImageJPEGRepresentation(Image, 0.5);
    //  } else {
    //    data = imageData;
    //  }
    
    //  NSData * data = UIImagePNGRepresentation(Image);
    //
    //
    //  if (data == nil) {
    //    NSData *data = UIImageJPEGRepresentation(Image, 1);
    //  }
    
    NSData *data = UIImageJPEGRepresentation(Image, 1);
    
    //图片保存的路径
    //这里将图片放在沙盒的documents文件夹中
    NSString * TemporaryPath = NSTemporaryDirectory();
    
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //把刚刚图片转换的data对象拷贝至沙盒中
    [fileManager createDirectoryAtPath:TemporaryPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    NSString * ImagePath = [[NSString alloc]initWithFormat:@"/%@.jpeg", timeSp];
    [fileManager createFileAtPath:[TemporaryPath stringByAppendingString:ImagePath] contents:data attributes:nil];
    
    //得到选择后沙盒中图片的完整路径
    filePath = [[NSString alloc]initWithFormat:@"%@%@",TemporaryPath,ImagePath];
    
    return filePath;
}

- (void)dewarpTest1 {
    L_DEWARP   *dew1, *dew2;
    L_DEWARPA  *dewa;
    PIX        *pixs, *pixn, *pixg, *pixb, *pixd, *pixt1, *pixt2;
    PIX        *pixs2, *pixn2, *pixg2, *pixb2, *pixd2;
    
    setLeptDebugOK(1);
    lept_mkdir("lept/model");
    
    /*    pixs = pixRead("1555.007.jpg"); */
    NSString *fileName = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/wx2.jpeg"];
    NSLog(@"fileName:%@", fileName);
    
    /*
    UIImage *OCImage = [UIImage imageNamed:@"wx8.jpeg"];
    
    cv::Mat img;
    UIImageToMat(OCImage, img);
    // 灰度处理
    cv::cvtColor(img, img, CV_BGR2GRAY);
    // 膨胀/
    cv::Mat dilated_img;
    cv::Mat element = cv::getStructuringElement(0, cv::Size(180, 180));
    cv::dilate(img, dilated_img, element);
    
    // 均值模糊 太耗时，而且用处不大
    //    cv::Mat bg_img;
    //    cv::medianBlur(dilated_img, bg_img, 21);
    cv::Mat diff_img;
    cv::absdiff(img, dilated_img, diff_img);
    diff_img = 255 - diff_img;
    
    cv::Mat norm_img;
    // 归一化处理
    cv::normalize(diff_img, norm_img, 0, 255, cv::NORM_MINMAX, CV_8UC1);
    
    // 二值化
    cv::Mat thresh_img;
    cv::threshold(norm_img, thresh_img, 205, 255, CV_THRESH_BINARY);    // 210
    
    cv::Mat thresh_img2;
    cv::adaptiveThreshold(thresh_img, thresh_img2, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 45, 2);
    
    //    results_norm_plane.push_back(thresh_img2);
    //  }
    //
    //  cv::Mat result_norm;
    //  cv::merge(results_norm_plane, result_norm);
    
//    // 侵蚀，优化文字空心问题
//    cv::Mat result_img;
//    cv::Mat element2 = cv::getStructuringElement(0, cv::Size(1, 1));
//    cv::erode(thresh_img2, result_img, element2);
    
    UIImage *newImage = MatToUIImage(thresh_img2);
    
    NSString *newImageString = [self getImagePath:newImage];
     */
    
    pixs = pixRead(fileName.UTF8String);
    /*    pixs = pixRead("cat.010.jpg"); */
    
    /* Normalize for varying background and binarize */
    pixn = pixBackgroundNormSimple(pixs, NULL, NULL);
    pixg = pixConvertRGBToGray(pixn, 0.5, 0.3, 0.2);
//    pixg = pixBackgroundNormSimple(pixs, NULL, NULL);
    pixb = pixThresholdToBinary(pixg, 180);
    
    /* Run the basic functions */
    dewa = dewarpaCreate(2, 30, 1, 1, 30);
    dewarpaUseBothArrays(dewa, 1);
    dew1 = dewarpCreate(pixb, 35);
    dewarpaInsertDewarp(dewa, dew1);
    dewarpBuildPageModel(dew1, "/tmp/lept/model/dewarp_model1.pdf");
    dewarpaApplyDisparity(dewa, 35, pixg, 200, 0, 0, &pixd,
                          "/tmp/lept/model/dewarp_apply1.pdf");
    
    /* Write out some of the files to be imaged */
    lept_rmdir("lept/dewtest");
    lept_mkdir("lept/dewtest");
    pixWrite("/tmp/lept/dewtest/001.jpg", pixs, IFF_JFIF_JPEG);
    pixWrite("/tmp/lept/dewtest/002.jpg", pixn, IFF_JFIF_JPEG);
    pixWrite("/tmp/lept/dewtest/003.jpg", pixg, IFF_JFIF_JPEG);
    pixWrite("/tmp/lept/dewtest/004.png", pixb, IFF_TIFF_G4);
    pixWrite("/tmp/lept/dewtest/005.jpg", pixd, IFF_JFIF_JPEG);
    pixt1 = pixRead("/tmp/lept/dewmod/0020.png");
    pixWrite("/tmp/lept/dewtest/006.png", pixt1, IFF_PNG);
    pixDestroy(&pixt1);
    pixt1 = pixRead("/tmp/lept/dewmod/0030.png");
    pixWrite("/tmp/lept/dewtest/007.png", pixt1, IFF_PNG);
    pixDestroy(&pixt1);
    pixt1 = pixRead("/tmp/lept/dewmod/0060.png");
    pixWrite("/tmp/lept/dewtest/008.png", pixt1, IFF_PNG);
    pixDestroy(&pixt1);
    pixt1 = pixRead("/tmp/lept/dewmod/0070.png");
    pixWrite("/tmp/lept/dewtest/009.png", pixt1, IFF_PNG);
    pixDestroy(&pixt1);
    pixt1 = pixRead("/tmp/lept/dewapply/002.png");
    pixWrite("/tmp/lept/dewtest/010.png", pixt1, IFF_PNG);
    pixDestroy(&pixt1);
    pixt1 = pixRead("/tmp/lept/dewapply/003.png");
    pixWrite("/tmp/lept/dewtest/011.png", pixt1, IFF_PNG);
    pixt2 = pixThresholdToBinary(pixt1, 130);
    pixWrite("/tmp/lept/dewtest/012.png", pixt2, IFF_TIFF_G4);
    pixDestroy(&pixt1);
    pixDestroy(&pixt2);
    pixt1 = pixRead("/tmp/lept/dewmod/0041.png");
    pixWrite("/tmp/lept/dewtest/013.png", pixt1, IFF_PNG);
    pixDestroy(&pixt1);
    pixt1 = pixRead("/tmp/lept/dewmod/0042.png");
    pixWrite("/tmp/lept/dewtest/014.png", pixt1, IFF_PNG);
    pixDestroy(&pixt1);
    pixt1 = pixRead("/tmp/lept/dewmod/0051.png");
    pixWrite("/tmp/lept/dewtest/015.png", pixt1, IFF_PNG);
    pixDestroy(&pixt1);
    pixt1 = pixRead("/tmp/lept/dewmod/0052.png");
    pixWrite("/tmp/lept/dewtest/016.png", pixt1, IFF_PNG);
    pixDestroy(&pixt1);
    
    /* Normalize another image, that may not have enough textlines
     * to build an accurate model */
    /*    pixs2 = pixRead("1555.003.jpg");  */
    NSString *fileName2 = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/cat.007.jpg"];
    pixs2 = pixRead(fileName2.UTF8String);
    /*    pixs2 = pixRead("cat.014.jpg"); */
    pixn2 = pixBackgroundNormSimple(pixs2, NULL, NULL);
    pixg2 = pixConvertRGBToGray(pixn2, 0.5, 0.3, 0.2);
    pixb2 = pixThresholdToBinary(pixg2, 130);
    
    /* Apply the previous disparity model to this image */
    dew2 = dewarpCreate(pixb2, 7);
    dewarpaInsertDewarp(dewa, dew2);
    dewarpaInsertRefModels(dewa, 0, 1);
    dewarpaInfo(stderr, dewa);
    dewarpaApplyDisparity(dewa, 7, pixg2, 200, 0, 0, &pixd2,
                          "/tmp/lept/model/dewarp_apply2.pdf");
    dewarpaDestroy(&dewa);
    
    /* Write out files for the second image */
    pixWrite("/tmp/lept/dewtest/017.jpg", pixs2, IFF_JFIF_JPEG);
    pixWrite("/tmp/lept/dewtest/018.jpg", pixg2, IFF_JFIF_JPEG);
    pixWrite("/tmp/lept/dewtest/019.png", pixb2, IFF_TIFF_G4);
    pixWrite("/tmp/lept/dewtest/020.jpg", pixd2, IFF_JFIF_JPEG);
    pixt1 = pixRead("/tmp/lept/dewmod/0060.png");
    pixWrite("/tmp/lept/dewtest/021.png", pixt1, IFF_PNG);
    pixDestroy(&pixt1);
    pixt1 = pixRead("/tmp/lept/dewapply/002.png");
    pixWrite("/tmp/lept/dewtest/022.png", pixt1, IFF_PNG);
    pixt2 = pixThresholdToBinary(pixt1, 130);
    pixWrite("/tmp/lept/dewtest/023.png", pixt2, IFF_TIFF_G4);
    pixDestroy(&pixt1);
    pixDestroy(&pixt2);
    pixt1 = pixRead("/tmp/lept/dewmod/0070.png");
    pixWrite("/tmp/lept/dewtest/024.png", pixt1, IFF_PNG);
    pixDestroy(&pixt1);
    pixt1 = pixRead("/tmp/lept/dewapply/003.png");
    pixWrite("/tmp/lept/dewtest/025.png", pixt1, IFF_PNG);
    pixt2 = pixThresholdToBinary(pixt1, 130);
    pixWrite("/tmp/lept/dewtest/026.png", pixt2, IFF_TIFF_G4);
    pixDestroy(&pixt1);
    pixDestroy(&pixt2);
    
    /* Generate the big pdf file */
    convertFilesToPdf("/tmp/lept/dewtest", NULL, 135, 1.0, 0, 0, "Dewarp Test",
                      "/tmp/lept/dewarptest1.pdf");
    fprintf(stderr, "pdf file made: /tmp/lept/model/dewarptest1.pdf\n");
//
//    lept_rmdir("lept/dewmod");
//    lept_rmdir("lept/dewtest");
    pixDestroy(&pixs);
    pixDestroy(&pixn);
    pixDestroy(&pixg);
    pixDestroy(&pixb);
    pixDestroy(&pixd);
    pixDestroy(&pixs2);
    pixDestroy(&pixn2);
    pixDestroy(&pixg2);
    pixDestroy(&pixb2);
    pixDestroy(&pixd2);
}

- (void)dewarpTest3 {
    l_int32     i, n;
    l_float32   a, b, c, d, e;
    NUMA       *nax, *nafit;
    PIX        *pixs, *pixn, *pixg, *pixb, *pixt1, *pixt2;
    PIXA       *pixa;
    PTA        *pta, *ptad;
    PTAA       *ptaa1, *ptaa2;
    
    setLeptDebugOK(1);
    lept_mkdir("lept");
    
    NSString *fileName = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/cat.035.jpg"];
    pixs = pixRead(fileName.UTF8String);
    /*    pixs = pixRead("zanotti-78.jpg"); */
    
    /* Normalize for varying background and binarize */
    pixn = pixBackgroundNormSimple(pixs, NULL, NULL);
    pixg = pixConvertRGBToGray(pixn, 0.5, 0.3, 0.2);
    pixb = pixThresholdToBinary(pixg, 130);
    pixDestroy(&pixn);
    pixDestroy(&pixg);
    
    /* Get the textline centers */
    pixa = pixaCreate(6);
    ptaa1 = dewarpGetTextlineCenters(pixb, 0);
    pixt1 = pixCreateTemplate(pixs);
    pixSetAll(pixt1);
    pixt2 = pixDisplayPtaa(pixt1, ptaa1);
    pixWrite("/tmp/lept/textline1.png", pixt2, IFF_PNG);
    pixDisplayWithTitle(pixt2, 0, 100, "textline centers 1", 1);
    pixaAddPix(pixa, pixt2, L_INSERT);
    pixDestroy(&pixt1);
    
    /* Remove short lines */
    fprintf(stderr, "Num all lines = %d\n", ptaaGetCount(ptaa1));
    ptaa2 = dewarpRemoveShortLines(pixb, ptaa1, 0.8, 0);
    pixt1 = pixCreateTemplate(pixs);
    pixSetAll(pixt1);
    pixt2 = pixDisplayPtaa(pixt1, ptaa2);
    pixWrite("/tmp/lept/textline2.png", pixt2, IFF_PNG);
    pixDisplayWithTitle(pixt2, 300, 100, "textline centers 2", 1);
    pixaAddPix(pixa, pixt2, L_INSERT);
    pixDestroy(&pixt1);
    n = ptaaGetCount(ptaa2);
    fprintf(stderr, "Num long lines = %d\n", n);
    ptaaDestroy(&ptaa1);
    pixDestroy(&pixb);
    
    /* Long lines over input image */
    pixt1 = pixCopy(NULL, pixs);
    pixt2 = pixDisplayPtaa(pixt1, ptaa2);
    pixWrite("/tmp/lept/textline3.png", pixt2, IFF_PNG);
    pixDisplayWithTitle(pixt2, 600, 100, "textline centers 3", 1);
    pixaAddPix(pixa, pixt2, L_INSERT);
    pixDestroy(&pixt1);
    
    /* Quadratic fit to curve */
    pixt1 = pixCopy(NULL, pixs);
    for (i = 0; i < n; i++) {
        pta = ptaaGetPta(ptaa2, i, L_CLONE);
        ptaGetArrays(pta, &nax, NULL);
        ptaGetQuadraticLSF(pta, &a, &b, &c, &nafit);
        fprintf(stderr, "Quadratic: a = %10.6f, b = %7.3f, c = %7.3f\n",
                a, b, c);
        ptad = ptaCreateFromNuma(nax, nafit);
        pixDisplayPta(pixt1, pixt1, ptad);
        ptaDestroy(&pta);
        ptaDestroy(&ptad);
        numaDestroy(&nax);
        numaDestroy(&nafit);
    }
    pixWrite("/tmp/lept/textline4.png", pixt1, IFF_PNG);
    pixDisplayWithTitle(pixt1, 900, 100, "textline centers 4", 1);
    pixaAddPix(pixa, pixt1, L_INSERT);
    
    /* Cubic fit to curve */
    pixt1 = pixCopy(NULL, pixs);
    for (i = 0; i < n; i++) {
        pta = ptaaGetPta(ptaa2, i, L_CLONE);
        ptaGetArrays(pta, &nax, NULL);
        ptaGetCubicLSF(pta, &a, &b, &c, &d, &nafit);
        fprintf(stderr, "Cubic: a = %10.6f, b = %10.6f, c = %7.3f, d = %7.3f\n",
                a, b, c, d);
        ptad = ptaCreateFromNuma(nax, nafit);
        pixDisplayPta(pixt1, pixt1, ptad);
        ptaDestroy(&pta);
        ptaDestroy(&ptad);
        numaDestroy(&nax);
        numaDestroy(&nafit);
    }
    pixWrite("/tmp/lept/textline5.png", pixt1, IFF_PNG);
    pixDisplayWithTitle(pixt1, 1200, 100, "textline centers 5", 1);
    pixaAddPix(pixa, pixt1, L_INSERT);
    
    /* Quartic fit to curve */
    pixt1 = pixCopy(NULL, pixs);
    for (i = 0; i < n; i++) {
        pta = ptaaGetPta(ptaa2, i, L_CLONE);
        ptaGetArrays(pta, &nax, NULL);
        ptaGetQuarticLSF(pta, &a, &b, &c, &d, &e, &nafit);
        fprintf(stderr,
                "Quartic: a = %7.3f, b = %7.3f, c = %9.5f, d = %7.3f, e = %7.3f\n",
                a, b, c, d, e);
        ptad = ptaCreateFromNuma(nax, nafit);
        pixDisplayPta(pixt1, pixt1, ptad);
        ptaDestroy(&pta);
        ptaDestroy(&ptad);
        numaDestroy(&nax);
        numaDestroy(&nafit);
    }
    pixWrite("/tmp/lept/textline6.png", pixt1, IFF_PNG);
    pixDisplayWithTitle(pixt1, 1500, 100, "textline centers 6", 1);
    pixaAddPix(pixa, pixt1, L_INSERT);
    
    pixaConvertToPdf(pixa, 300, 0.5, L_JPEG_ENCODE, 75,
                     "LS fittings to textlines",
                     "/tmp/lept/dewarp_fittings.pdf");
    pixaDestroy(&pixa);
    pixDestroy(&pixs);
    ptaaDestroy(&ptaa2);
}

- (void)dewarpTest4 {
    L_DEWARP   *dew1, *dew2, *dew3;
    L_DEWARPA  *dewa1, *dewa2, *dewa3;
    PIX        *pixs, *pixn, *pixg, *pixb, *pixd;
    PIX        *pixs2, *pixn2, *pixg2, *pixb2, *pixd2;
    PIX        *pixd3, *pixc1, *pixc2;
    
    setLeptDebugOK(1);
    lept_mkdir("lept");
    
    NSString *fileName = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/cat.035.jpg"];
    /*    pixs = pixRead("1555.007.jpg"); */
    pixs = pixRead(fileName.UTF8String);
    dewa1 = dewarpaCreate(40, 30, 1, 15, 10);
    dewarpaUseBothArrays(dewa1, 1);
    
    /* Normalize for varying background and binarize */
    pixn = pixBackgroundNormSimple(pixs, NULL, NULL);
    pixg = pixConvertRGBToGray(pixn, 0.5, 0.3, 0.2);
    pixb = pixThresholdToBinary(pixg, 130);
    
    /* Run the basic functions */
    dew1 = dewarpCreate(pixb, 35);
    dewarpaInsertDewarp(dewa1, dew1);
    dewarpBuildPageModel(dew1, "/tmp/lept/dewarp_junk35.pdf");
    dewarpPopulateFullRes(dew1, pixg, 0, 0);
    dewarpaApplyDisparity(dewa1, 35, pixg, 200, 0, 0, &pixd,
                          "/tmp/lept/dewarp_debug_35.pdf");
    
    /* Normalize another image. */
    /*    pixs2 = pixRead("1555.003.jpg"); */
    NSString *fileName2 = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/cat.007.jpg"];
    pixs2 = pixRead(fileName2.UTF8String);
    pixn2 = pixBackgroundNormSimple(pixs2, NULL, NULL);
    pixg2 = pixConvertRGBToGray(pixn2, 0.5, 0.3, 0.2);
    pixb2 = pixThresholdToBinary(pixg2, 130);
    
    /* Run the basic functions */
    dew2 = dewarpCreate(pixb2, 7);
    dewarpaInsertDewarp(dewa1, dew2);
    dewarpBuildPageModel(dew2, "/tmp/lept/dewarp_junk7.pdf");
    dewarpaApplyDisparity(dewa1, 7, pixg, 200, 0, 0, &pixd2,
                          "/tmp/lept/dewarp_debug_7.pdf");
    
    /* Serialize and deserialize dewarpa */
    dewarpaWrite("/tmp/lept/dewarpa1.dewa", dewa1);
    dewa2 = dewarpaRead("/tmp/lept/dewarpa1.dewa");
    dewarpaWrite("/tmp/lept/dewarpa2.dewa", dewa2);
    dewa3 = dewarpaRead("/tmp/lept/dewarpa2.dewa");
    dewarpDebug(dewa3->dewarp[7], "dew1", 7);
    dewarpaWrite("/tmp/lept/dewarpa3.dewa", dewa3);
    
    /* Repopulate and show the vertical disparity arrays */
    dewarpPopulateFullRes(dew1, NULL, 0, 0);
    pixc1 = fpixRenderContours(dew1->fullvdispar, 2.0, 0.2);
    pixDisplay(pixc1, 1400, 900);
    dew3 = dewarpaGetDewarp(dewa2, 35);
    dewarpPopulateFullRes(dew3, pixs, 0, 0);
    pixc2 = fpixRenderContours(dew3->fullvdispar, 2.0, 0.2);
    pixDisplay(pixc2, 1400, 900);
    dewarpaApplyDisparity(dewa2, 35, pixb, 200, 0, 0, &pixd3,
                          "/tmp/lept/dewarp_debug_35b.pdf");
    pixDisplay(pixd, 0, 1000);
    pixDisplay(pixd2, 600, 1000);
    pixDisplay(pixd3, 1200, 1000);
    pixDestroy(&pixd3);
    
    dewarpaDestroy(&dewa1);
    dewarpaDestroy(&dewa2);
    dewarpaDestroy(&dewa3);
    pixDestroy(&pixs);
    pixDestroy(&pixn);
    pixDestroy(&pixg);
    pixDestroy(&pixb);
    pixDestroy(&pixd);
    pixDestroy(&pixs2);
    pixDestroy(&pixn2);
    pixDestroy(&pixg2);
    pixDestroy(&pixb2);
    pixDestroy(&pixd2);
    pixDestroy(&pixc1);
    pixDestroy(&pixc2);
}

static l_int32 pageno = 35;
static l_int32 build_output = 0;
static l_int32 apply_output = 0;
static l_int32 map_output = 1;
- (void)dewarpTest5 {
    char        buf[64];
    BOXA       *boxa1, *boxa2, *boxa3, *boxa4;
    L_DEWARP   *dew;
    L_DEWARPA  *dewa;
    PIX        *pixs, *pixn, *pixg, *pixb, *pix2, *pix3, *pix4, *pix5, *pix6;
    
    setLeptDebugOK(1);
    lept_mkdir("lept");
    
    snprintf(buf, sizeof(buf), "cat.%03d.jpg", pageno);
    pixs = pixRead(buf);
    dewa = dewarpaCreate(40, 30, 1, 15, 10);
    dewarpaUseBothArrays(dewa, 1);
    
    /* Normalize for varying background and binarize */
    pixn = pixBackgroundNormSimple(pixs, NULL, NULL);
    pixg = pixConvertRGBToGray(pixn, 0.5, 0.3, 0.2);
    pixb = pixThresholdToBinary(pixg, 130);
    pixDisplay(pixb, 0, 100);
    
    /* Build the model */
    dew = dewarpCreate(pixb, pageno);
    dewarpaInsertDewarp(dewa, dew);
    if (build_output) {
        snprintf(buf, sizeof(buf), "/tmp/lept/dewarp_build_%d.pdf", pageno);
        dewarpBuildPageModel(dew, buf);
    } else {
        dewarpBuildPageModel(dew, NULL);
    }
    
    /* Apply the model */
    dewarpPopulateFullRes(dew, pixg, 0, 0);
    if (apply_output) {
        snprintf(buf, sizeof(buf), "/tmp/lept/dewarp_apply_%d.pdf", pageno);
        dewarpaApplyDisparity(dewa, pageno, pixb, 200, 0, 0, &pix2, buf);
    } else {
        dewarpaApplyDisparity(dewa, pageno, pixb, 200, 0, 0, &pix2, NULL);
    }
    pixDisplay(pix2, 200, 100);
    
    /* Reverse direction: get the word boxes for the dewarped pix ... */
    pixGetWordBoxesInTextlines(pix2, 5, 5, 500, 100, &boxa1, NULL);
    pix3 = pixConvertTo32(pix2);
    pixRenderBoxaArb(pix3, boxa1, 2, 255, 0, 0);
    pixDisplay(pix3, 400, 100);
    
    /* ... and map to the word boxes for the input image */
    if (map_output) {
        snprintf(buf, sizeof(buf), "/tmp/lept/dewarp_map1_%d.pdf", pageno);
        dewarpaApplyDisparityBoxa(dewa, pageno, pix2, boxa1, 0, 0, 0, &boxa2,
                                  buf);
    } else {
        dewarpaApplyDisparityBoxa(dewa, pageno, pix2, boxa1, 0, 0, 0, &boxa2,
                                  NULL);
    }
    pix4 = pixConvertTo32(pixb);
    pixRenderBoxaArb(pix4, boxa2, 2, 0, 255, 0);
    pixDisplay(pix4, 600, 100);
    
    /* Forward direction: get the word boxes for the input pix ... */
    pixGetWordBoxesInTextlines(pixb, 5, 5, 500, 100, &boxa3, NULL);
    pix5 = pixConvertTo32(pixb);
    pixRenderBoxaArb(pix5, boxa3, 2, 255, 0, 0);
    pixDisplay(pix5, 800, 100);
    
    /* ... and map to the word boxes for the dewarped image */
    if (map_output) {
        snprintf(buf, sizeof(buf), "/tmp/lept/dewarp_map2_%d.pdf", pageno);
        dewarpaApplyDisparityBoxa(dewa, pageno, pixb, boxa3, 1, 0, 0, &boxa4,
                                  buf);
    } else {
        dewarpaApplyDisparityBoxa(dewa, pageno, pixb, boxa3, 1, 0, 0, &boxa4,
                                  NULL);
    }
    pix6 = pixConvertTo32(pix2);
    pixRenderBoxaArb(pix6, boxa4, 2, 0, 255, 0);
    pixDisplay(pix6, 1000, 100);
    
    dewarpaDestroy(&dewa);
    pixDestroy(&pixs);
    pixDestroy(&pixn);
    pixDestroy(&pixg);
    pixDestroy(&pixb);
    pixDestroy(&pix2);
    pixDestroy(&pix3);
    pixDestroy(&pix4);
    pixDestroy(&pix5);
    pixDestroy(&pix6);
    boxaDestroy(&boxa1);
    boxaDestroy(&boxa2);
    boxaDestroy(&boxa3);
    boxaDestroy(&boxa4);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
