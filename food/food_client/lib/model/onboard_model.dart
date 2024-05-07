class OnBoardingContent {
  OnBoardingContent({
    required this.title,
    required this.description,
    required this.image,
  });

  final String title;
  final String description;
  final String image;
}

List<OnBoardingContent> contents = [
  OnBoardingContent(
    title: 'Select from Our\n     Best Menu',
    description: 'Pick your food from our menu\n        More than 35 times ',
    image: 'assets/images/screen1.png',
  ),
  OnBoardingContent(
    title: 'Easy and Online Payment',
    description:
        'You can pay cash on delivery and\n       Card payment is available',
    image: 'assets/images/screen2.png',
  ),
  OnBoardingContent(
    title: 'Quick Delivery at your Doorstep',
    description: 'Deliver your food at your\n       Doorstep',
    image: 'assets/images/screen3.png',
  ),
];
