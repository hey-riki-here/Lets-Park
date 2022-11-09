import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: const Text(
          "Privacy Policy",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "1. Introduction",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              buildArticle(
                "i. Let's Park! (\"we\" or \"us\") take your information's privacy very seriously. This policy explains how and why we utilize the data we obtain about you via our website and mobile app (referred to below as \"the Service\"). Please carefully read our privacy statement. You agree to be bound by this policy with regards to the information about you obtained through this site by using the Service.",
              ),
              const SizedBox(height: 10),
              buildArticle(
                  "ii. Please contact us if you have any questions about the policy, and we'll try our best to respond."),
              const SizedBox(height: 10),
              buildArticle(
                  "iii. You are responsible for regularly checking to see if you still agree to abide by the policy because we review it on a regular basis. You must discontinue using the Service right away if you object to any modifications made to this policy."),
              const SizedBox(height: 10),
              buildArticle(
                  "iv. It is important that the personal information we hold about you is true, complete, accurate and current."),
              const SizedBox(height: 20),
              const Text(
                "2. Personal information collected and use of this information",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              buildRichTextArticle(
                "i. ",
                "Account Data",
                " - although it is not compulsory to give us this information, if you do not then you cannot register as a member of the Service, or make a booking for a parking space with our parking space operators we will collect the following data:",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "a. ",
                "Name",
                " - we need to store this to identify you in the provision of our service. It will be shared with parking space operators you make a booking with and users on our platform which you send messages to.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "b. ",
                "Email",
                " - we’ll send emails to you about your bookings and the Let's Park! service. We may share your email with third parties (including parking space operators).",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "c. ",
                "Photo",
                " - if you upload a photo, we provide it to parking space operators so they can identify you and we use it to personalise any reviews you leave about parking spaces.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "d. ",
                "Payment method",
                " - payment method details you provide (including name, email address and sometimes address) are sent directly to PCI-compliant third party payment providers. They are not stored on Let's Park! servers and developers do not have access to these details.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "e. ",
                "Booking history",
                " - we need to store this to identify you in the provision of our service. It will be shared with parking space operators you make a booking with and users on our platform which you send messages to.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "f. ",
                "Phone number",
                " - we store this so drivers can contact parking space operators and vice versa. Users may contact you via phone should there be any issues with your bookings or account.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "g. ",
                "Reviews",
                " - if you choose to leave a review for a parking location, this will be shown to other drivers considering booking the space (only showing your first name and your last name).",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "g. ",
                "Location data",
                " - if you choose to enable location services, we will occasionally store your location services data to improve our parking availability engine - which helps us show you and other drivers when we think spaces will be available to park in. You can stop this data from being stored by turning off your location services.",
              ),
              const SizedBox(height: 10),
              buildRichTextArticle(
                "ii. ",
                "Parking Space Listing Data",
                " - to list your parking space with us we will collect the following data:",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "a. ",
                "Parking space address",
                " - we use this to show drivers where your space is. We will reveal address to them so that they can navigate there. The driver can also see a map pin showing the location of your space.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "b. ",
                "Space description",
                " - this is a description you provide when adding your space which helps drivers decide if a space is suitable.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "c. ",
                "Photos of your space",
                " - these photos help drivers decide if a space is suitable and help them access it on arrival.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "d. ",
                "Rules in the parking space",
                " - these are the rules imposed by the parking space operators to guide the drivers park inside the parking space.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "e. ",
                "Legal Documents / Certificates",
                " - these documents are shown to let the drivers know that the parking space is legally owned.",
              ),
              const SizedBox(height: 10),
              buildRichTextArticle(
                "iii. ",
                "How we use your information",
                " - We collect and use your information so that we can operate effectively and provide you with the best experience when you use our app and/or web products. We also use the information we collect for the following purposes:",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "1. ",
                "Fulfillment of parking transactions",
                " - such as completing your parking transaction.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "2. ",
                "Customer support",
                " - such as notifying you of any changes to our services; responding to your inquiries via email.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "3. ",
                "Improving our services",
                " - such as conducting data analysis and audits; developing new products and services; enhancing our website and mobile app to improve our services.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "4. ",
                "Legal proceedings and requirements",
                " - such as investigating or addressing claims or disputes relating to your use of our services; or as otherwise allowed by applicable law; or as requested by regulators, government entities, and official inquiries.",
              ),
              const SizedBox(height: 10),
              buildRichTextArticle(
                "iv. ",
                "How and when we share your information",
                " - We may share the information we collect with:",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "1. ",
                "Third-party companies, service providers",
                " -  We rely on third parties to perform a few contractual services on our behalf. To do so, we may need to share your information with them. For example, we may rely on service providers to enable functionality on our Services, to process your payments, and for other business purposes.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "2. ",
                "Municipalities and private parking operators",
                " -  We share your information with our municipality and other business partners with whom we have a contractual agreement in order to provide services to you. For example, our partners will have access to your vehicle information for parking enforcement purposes. By purchasing or reserving parking through the Services, you understand and direct us to share your vehicle, and other personal information with whichever of our partners controls the parking inventory that you are purchasing or reserving.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "3. ",
                "Your consent",
                " -  We may share your information other than as described in this policy if we notify you, and you agree.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "4. ",
                "Other services",
                " -  We may share your information with third parties to enable you to sign up for or log in to Let's Park!, or when you decide to link your Let's Park! account to those services.",
              ),
              const SizedBox(height: 10),
              buildRichTextArticle(
                "v. ",
                "How we use cookies",
                " -  When you visit the Site we may store some information (commonly known as a \"cookie\") on your computer.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "a. ",
                "Cookies",
                " are pieces of information that a website transfers to your hard drive to store and sometimes track information about you. Cookies are specific to the server that created them and cannot be accessed by other servers, which means that they cannot be used to track your movements around the web. Passwords and credit card numbers are not stored in cookies. A cookie helps you get the best out of the Site and helps us to provide you with a more customised service. We use cookies for the following purposes:",
              ),
              const SizedBox(height: 10),
              buildSubSubRichTextArticle(
                "1. ",
                "",
                " Storing details about your site preferences (for instance, where you are based);",
              ),
              const SizedBox(height: 10),
              buildSubSubRichTextArticle(
                "2. ",
                "",
                " Enabling our web server to track your session between pages of the site and provide a continuity of experience.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "b. ",
                "",
                " You can block or erase cookies from your computer if you want to (your browser's help screen or manual should tell you how to do this), but certain parts of the Site are reliant on the use of cookies to operate correctly and may not work correctly if you set your browser not to accept cookies.",
              ),
              const SizedBox(height: 10),
              buildRichTextArticle(
                "vi. ",
                "Sensitive Personal Information",
                " - We won't ask you for any delicate personal data. Only when absolutely necessary, such as if we suspect you are having trouble managing your account, will we ask you for sensitive personal information. If we ask for such data, we will be clear about why and how we plan to utilize it.",
              ),
              const SizedBox(height: 10),
              buildRichTextArticle(
                "vii. ",
                "Legal Rights",
                " - You may be entitled to various protections under data protection regulations with regard to your personal information. These consist of the following:",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "•",
                "",
                " Request access to your personal data.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "•",
                "",
                " Request correction of your personal data.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "•",
                "",
                " Request erasure of your personal data (Also known as the Right to be Forgotten).",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "•",
                "",
                " Object to processing of your personal data.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "•",
                "",
                " Request restriction of processing your personal data.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "•",
                "",
                " Request transfer of your personal data.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "•",
                "",
                " Right to withdraw consent.",
              ),
              const SizedBox(height: 10),
              buildArticle(
                "To correct or erase your data, you can do this via the account settings of the mobile app. To exercise any of the other rights please get in touch. You won't be charged a price to view your personal information (or to exercise any of the other rights). However, if your request is obviously baseless, repeated, or unreasonable, we may charge a reasonable price. In some situations, we may also decline to abide with your request. In order to verify your identity and establish that you have the right to access your personal data, we might need to ask you for certain information (or to exercise any of your other rights). This is a security safeguard to make sure that personal information is not given to someone who shouldn't have access to it. In order to respond to your request more quickly, we might possibly get in touch with you and ask you for more details. We make an effort to respond to all valid inquiries within a month. Occasionally, if your request is exceptionally complicated or you have made several requests, it can take us more than a month. In this scenario, we'll let you know and keep you informed.",
              ),
              const SizedBox(height: 10),
              buildRichTextArticle(
                "viii. ",
                "Data retention",
                "",
              ),
              const SizedBox(height: 10),
              buildSubSubRichTextArticle(
                "i. ",
                "",
                " After consenting to us using your data as described in this policy, we will retain it on our system for as long as we deem to be a period within which you may return to use your account. This varies from individual to individual depending on account activity. After that period we will close your account and delete your data in line with this policy.",
              ),
              const SizedBox(height: 10),
              buildSubSubRichTextArticle(
                "ii. ",
                "",
                " You can remove your personal data from Let's Park! at any time by deleting your account as described above. However, we may keep some of your Personal Data for as long as reasonably necessary for our legitimate business interests, including fraud detection and prevention and to comply with our legal obligations including tax, legal reporting, and auditing obligations.",
              ),
              const SizedBox(height: 20),
              const Text(
                "3. Other sites",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              buildSubSubRichTextArticle(
                "i. ",
                "",
                " We cannot be responsible for the privacy policies and practices of other sites even if you access them using links from our Site and recommend that you check the policy of each site you visit and contact its owner or operator if you have any concerns or questions.",
              ),
              const SizedBox(height: 10),
              buildSubSubRichTextArticle(
                "ii. ",
                "",
                " In addition, if you linked to this Site from a third party site, we cannot be responsible for the privacy policies and practices of the owners or operators of that third party site and recommend that you check the policy of that third party site and contact its owner or operator if you have any concerns or questions.",
              ),
              const SizedBox(height: 20),
              const Text(
                "4. Further Questions",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              buildSubSubRichTextArticle(
                "",
                "",
                "If at any time you would like to contact us with your views about our privacy practices, or with any inquiry relating to your personal information, you can do so by sending us an email.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildArticle(String article) {
    return Row(
      children: [
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            article,
          ),
        ),
      ],
    );
  }

  Widget buildRichTextArticle(
    String articleNumber,
    String articleName,
    String article,
  ) {
    return Row(
      children: [
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: articleNumber,
              style: const TextStyle(
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: articleName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: article,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSubRichTextArticle(
    String articleNumber,
    String articleName,
    String article,
  ) {
    return Row(
      children: [
        const SizedBox(width: 20),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: articleNumber,
              style: const TextStyle(
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: articleName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: article,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSubSubRichTextArticle(
    String articleNumber,
    String articleName,
    String article,
  ) {
    return Row(
      children: [
        const SizedBox(width: 30),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: articleNumber,
              style: const TextStyle(
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: articleName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: article,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
