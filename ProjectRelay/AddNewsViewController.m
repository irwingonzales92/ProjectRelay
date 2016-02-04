//
//  AddNewsViewController.m
//  ProjectRelay
//
//  Created by Irwin Gonzales on 12/8/15.
//  Copyright © 2015 Irwin Gonzales. All rights reserved.
//

#import "AddNewsViewController.h"
#import <Parse/Parse.h>
#import "BackendFunctions.h"
#import "Article.h"
#import "JVFloatLabeledTextField.h"
#import "kColorConstants.h"


@interface AddNewsViewController () <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *articleTitleTextField;
@property (strong, nonatomic) IBOutlet UITextField *articleLinkTextField;
@property (weak, nonatomic) IBOutlet UITextField *addTagTextField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UIImageView *articleImageView;
@property (strong, nonatomic) UIAlertController *alert;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIImage *addPhotoImage;
@property (strong, nonatomic) NSURL *documents;
@property (strong, nonatomic) NSURL *filePath;
@property (strong, nonatomic) Article *article;
@property (strong, nonatomic) PFObject *tag;

@end

@implementation AddNewsViewController

- (void)dealloc
{
    //Degister for the notification.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _article = [Article new];
    _descriptionTextView.textColor = [UIColor lightGrayColor];
    _imagePicker = [UIImagePickerController new];
    [self.view bringSubviewToFront:_articleImageView];

    [self setDelegates];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
    //Register for Notifications and listen to "savedToParseSuccess" and perform a selector
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successfullyPostedToParse) name:@"savedToParseSuccess" object:nil];
}

- (void)successfullyPostedToParse
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setDelegates
{
    _articleLinkTextField.delegate = self;
    _articleTitleTextField.delegate = self;
    _addTagTextField.delegate = self;
    _descriptionTextView.delegate = self;
    _imagePicker.delegate = self;
}

- (void)hideKeyboard
{
    [_articleLinkTextField resignFirstResponder];
    [_articleTitleTextField resignFirstResponder];
    [_addTagTextField resignFirstResponder];
    [_descriptionTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.descriptionTextView.text = @"";
}
- (IBAction)addImageOnButtonPressed:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take A Photo"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action)
                                      {
                                          [_imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                                          [self presentViewController:_imagePicker animated:YES completion:nil];
                                      }];
    
    UIAlertAction *chooseFromLibrary = [UIAlertAction actionWithTitle:@"Choose From Library"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action)
                                        {
                                            [_imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                                            [self presentViewController:_imagePicker animated:YES completion:nil];
                                        }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    
    [alert addAction:takePhotoAction];
    [alert addAction:chooseFromLibrary];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    _addPhotoImage = image;
    _articleImageView.image = _addPhotoImage;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)articleSubmittedOnButtonPressed:(UIButton *)sender
{

    if ([self.articleTitleTextField.text isEqualToString:@""])
    {
        _alert = [BackendFunctions showDataEntryError:@"Error" withMessage:@"Did You Leave The Title Blank?"];
        [self presentViewController:_alert animated:YES completion:nil];

    }
    else if ([self.articleLinkTextField.text isEqualToString:@""])
    {
        _alert = [BackendFunctions showDataEntryError:@"Error" withMessage:@"Did You Forget To Enter A Link?"];
        [self presentViewController:_alert animated:YES completion:nil];
    }
    else if ([self.descriptionTextView.text isEqualToString:@""])
    {
        _alert = [BackendFunctions showDataEntryError:@"Error" withMessage:@"Did You Leave The Description Blank?"];
        [self presentViewController:_alert animated:YES completion:nil];
    }
    else
    {
        [BackendFunctions saveArticleWithTitle:_articleTitleTextField
                                   description:_descriptionTextView
                                         image:_addPhotoImage
                                        andUrl:_articleLinkTextField
                                       tagName:_addTagTextField];
    }
}

#pragma
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}


@end