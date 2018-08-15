//
//  ViewController.m
//  draw-Demo
//
//  Created by yesdgq on 2018/8/15.
//  Copyright © 2018年 yesdgq. All rights reserved.
//

#import "ViewController.h"
#import <CoreText/CoreText.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 375, 375)];
    [self.view addSubview:iv];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        CGRect rect = CGRectMake(0, 0, 200, 200);
        
        // 开启图形上下文
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
        
        // 获取图形上下文
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // 背景颜色
        [[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1] set];
        [[UIColor lightGrayColor] set];
        
        // 通过rect填充背景色
        CGContextFillRect(context, rect);
        
        // 绘制文字  脱离了 UILabel 的纯文本的绘制
        NSString *string = @"绘制图片文字";
        [string drawInRect:CGRectMake(20, 20, 160, 20) withAttributes:@{
                                                                       NSForegroundColorAttributeName:[UIColor colorWithRed:0/255.0 green:100/255.0 blue:100/255.0 alpha:1] ,
                                                                       NSFontAttributeName:[UIFont systemFontOfSize:10]}
         ];
        
        [self string:string drawInContext:context withPosition:CGPointMake(20, 50) andFont:[UIFont systemFontOfSize:10] andTextColor:[UIColor colorWithRed:0/255.0 green:100/255.0 blue:100/255.0 alpha:1] andHeight:20 andWidth:260];
        
        // 绘制本地图片
        [[UIImage imageNamed:@"share_wechat"] drawInRect:CGRectMake(20, 100, 30, 30) blendMode:kCGBlendModeNormal alpha:1];

        // 异步绘制 UILabel

        
        
        // 将整个contex转化为图片，赋给背景imageView
        UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
        
        
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            iv.image = temp;
            
            // 对比
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(200, 20, 160, 20)];
            label.text = string;
            label.textColor = [UIColor colorWithRed:0/255.0 green:100/255.0 blue:100/255.0 alpha:1];
            label.font = [UIFont systemFontOfSize:10];
            [iv addSubview:label];
            
        });
        
        
    });
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)string:(NSString *)str drawInContext:(CGContextRef)context withPosition:(CGPoint)p andFont:(UIFont *)font andTextColor:(UIColor *)color andHeight:(float)height andWidth:(float)width {
    
    CGSize size = CGSizeMake(width, font.pointSize+10);
    
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    
    //移动坐标系统，所有点的y增加了height
    CGContextTranslateCTM(context,0,height);
    
    //缩放坐标系统，所有点的x乘以1.0，所有的点的y乘以-1.0
    CGContextScaleCTM(context,1.0,-1.0);
    
    //文字颜色
    UIColor* textColor = color;
    
    //生成CTFont
    CTFontRef font1 = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize,NULL);
    
    //用于创建CTParagraphStyleRef的一些基本数据
    CGFloat minimumLineHeight = font.pointSize,maximumLineHeight = minimumLineHeight+10, linespace = 5;
    CTLineBreakMode lineBreakMode = kCTLineBreakByTruncatingTail;
    
    //左对齐
    CTTextAlignment alignment = kCTTextAlignmentLeft;
    
    //创建CTParagraphStyleRef
    CTParagraphStyleRef style = CTParagraphStyleCreate((CTParagraphStyleSetting[6]){
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
        {kCTParagraphStyleSpecifierMinimumLineHeight,sizeof(minimumLineHeight),&minimumLineHeight},
        {kCTParagraphStyleSpecifierMaximumLineHeight,sizeof(maximumLineHeight),&maximumLineHeight},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(linespace), &linespace},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(linespace), &linespace},
        {kCTParagraphStyleSpecifierLineBreakMode,sizeof(CTLineBreakMode),&lineBreakMode}
    },6);
    
    //设置属性字典；对象，key
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (__bridge id)font1,(NSString*)kCTFontAttributeName,
                                textColor.CGColor,kCTForegroundColorAttributeName,
                                style,kCTParagraphStyleAttributeName,
                                nil];
    
    //生成path，添加到cgcontex上
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path,NULL,CGRectMake(p.x, height-p.y-size.height,(size.width),(size.height)));
    
    //生成CF属性字符串
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:str attributes:attributes];
    CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)attributedStr;
    
    //从attributedString拿到ctframesetter
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    
    //从framesetter拿到 core text 的 ctframe
    CTFrameRef ctframe = CTFramesetterCreateFrame(framesetter, CFRangeMake(0,CFAttributedStringGetLength(attributedString)),path,NULL);
    
    //将ctframe绘制到context里面
    CTFrameDraw(ctframe,context);
    
    //因为不是对象类型，需要释放
    CGPathRelease(path);
    CFRelease(font1);
    CFRelease(framesetter);
    CFRelease(ctframe);
    [[attributedStr mutableString] setString:@""];
    
    //恢复context坐标系统
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    CGContextTranslateCTM(context,0, height);
    CGContextScaleCTM(context,1.0,-1.0);
}




@end
