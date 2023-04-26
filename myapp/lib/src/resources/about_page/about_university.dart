import 'package:flutter/material.dart';

class AboutUniversity extends StatefulWidget{
  @override
  _AboutUniversityState createState() => new _AboutUniversityState();
}

class _AboutUniversityState extends State<AboutUniversity>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new  AppBar(
        title: new Text('Giới thiệu về trường'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
        constraints: BoxConstraints.expand(),
        color: Colors.white,

        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
            SizedBox(
            height: 140,
          ),
          Image.asset('logo_page.png'),
          Padding(padding: EdgeInsets.fromLTRB(0, 20, 20, 6),
          ),
              Text("Trường đại học Sư phạm Kỹ thuật Thành phố Hồ Chí Minh"
                  "\nHCMC University of Technology and Education",
                style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Text(
                  "VÀI NÉT VỀ LỊCH SỬ",
                  style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 40),
              child: Text(
                "    Trường đại học Sư phạm Kỹ thuật Tp. Hồ Chí Minh được hình thành và phát triển trên cơ sở Ban Cao đẳng Sư phạm Kỹ thuật - thành lập ngày 05.10.1962. Ngày 21.9.1972, Trường được đổi tên thành Trung tâm Cao đẳng Sư phạm Kỹ thuật Nguyễn Trường Tộ Thủ Đức và được nâng cấp thành Trường đại học Giáo dục Thủ Đức vào năm 1974."
                    "\n    Ngày 27.10.1976, Thủ tướng Chính phủ đã ký quyết định thành lập Trường đại học Sư phạm Kỹ thuật Thủ Đức trên cơ sở Trường đại học Giáo dục Thủ Đức. Năm 1984, Trường đại học Sư phạm Kỹ thuật Thủ Đức hợp nhất với Trường trung học Công nghiệp Thủ Đức và đổi tên thành Trường đại học Sư phạm Kỹ thuật Tp. Hồ Chí Minh. Năm 1991, Trường đại học Sư phạm Kỹ thuật Tp. Hồ Chí Minh sát nhập thêm Trường Sư phạm Kỹ thuật 5 và phát triển cho đến ngày nay."
                    "\n    Nằm ở cửa ngõ phía bắc Tp. Hồ Chí Minh, cách trung tâm thành phố khoảng 10 km, tọa lạc tại số 1 Võ Văn Ngân, quận Thủ Đức, Trường đại học Sư phạm Kỹ thuật Tp. Hồ Chí Minh tập hợp được các ưu điểm của một cơ sở học tập rộng rãi, khang trang, an toàn, nằm ở ngoại ô nhưng giao thông bằng xe bus vào các khu vực của thành phố, đến sân bay và các vùng lân cận rất thuận tiện."
                    "",
                style: TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.justify,

              ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Text(
                  "CHỨC NĂNG, NHIỆM VỤ",
                  style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 40),
                child: Text(
                  "    Đào tạo và bồi dưỡng giáo viên kỹ thuật cho các trường đại học, cao đẳng, trung cấp chuyên nghiệp và dạy nghề, các trường phổ thông trung học."
                      "\n    Đào tạo đội ngũ kỹ sư công nghệ và bồi dưỡng nguồn nhân lực lao động kỹ thuật thích ứng với thị trường lao động."
                      "\n    Nghiên cứu khoa học và phục vụ sản xuất trên các lĩnh vực giáo dục chuyên nghiệp và khoa học công nghệ."
                      "\n    Quan hệ hợp tác với các cơ sở khoa học và đào tạo giáo viên kỹ thuật ở nước ngoài.",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  textAlign: TextAlign.justify,

                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Text(
                  "CHÍNH SÁCH CHẤT LƯỢNG",
                  style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 40),
                child: Text(
                  "    Không ngừng nâng cao chất lượng dạy, học, nghiên cứu khoa học nhằm cung cấp cho người học những điều kiện tốt nhất để phát triển toàn diện các năng lực, đáp ứng nhu cầu phát triển kinh tế, xã hội của đất nước và hội nhập quốc tế",
               style: TextStyle(fontSize: 16, color: Colors.black),
                  textAlign: TextAlign.justify,

                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Text(
                  "THÀNH TÍCH CỦA TRƯỜNG",
                  style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 40),
                child: Text(
                  "    Nhà trường được Chủ tịch nước tặng thưởng Huân chương Độc lập hạng ba (năm 2007), Huân chương Lao động hạng Nhất (năm 2001), Huân chương Lao động hạng Nhì (năm 1996), Huân chương Lao động hạng Ba (năm 1985)."
                      "\n    Đảng bộ trường được công nhận là “Đảng bộ Trong sạch - Vững mạnh - Xuất sắc” 13 năm liền (1995-2008)."
                      "\n    Công đoàn trường được Chủ tịch nước tặng thưởng Huân chương Lao động hạng Nhì (năm 2005), Huân chương Lao động hạng Ba (năm 2000); Công đoàn ngành Giáo dục Việt Nam và Liên đoàn Lao động thành phố Hồ Chí Minh tặng cờ “Công đoàn cơ sở Vững mạnh Xuất sắc” trong 12 năm liên tục."
                      "\n    Đoàn Thanh niên được Chủ tịch nước tặng Huân chương Lao động hạng Ba năm 2004. Đoàn Thanh niên và Hội sinh viên là đơn vị xuất sắc trong khối các trường ĐH, CĐ khu vực thành phố Hồ Chí Minh nhiều năm liền."
                      "\n    Nhiều đơn vị và các nhân của trường được Chính phủ và Bộ Giáo dục và Đào tạo tặng bằng khen; có 13 giáo viên được phong tặng danh hiệu Nhà giáo ưu tú và nhiều cán bộ, viên chức được tặng Huy chương vì sự nghiệp Giáo dục.",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  textAlign: TextAlign.justify,

                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Text(
                  "ĐỊNH HƯỚNG PHÁT TRIỂN CỦA TRƯỜNG",
                  style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 40),
                child: Text(
                  "    Phấn đấu trở thành một trong tốp 10 trường đại học hàng đầu của Việt Nam theo các tiêu chí kiểm định chất lượng trường đại học, trên một số mặt ngang tầm với những trường có uy tín của các nước trong khu vực; Trở thành một trường đa lĩnh vực; Sinh viên tốt nghiệp có việc làm phù hợp và phát huy được năng lực của mình một cách tối đa để cống hiến cho xã hội. Chương trình đào tạo có tính thích ứng cao, bằng cấp của Trường được công nhận một cách rộng rãi trong khu vực và thế giới. Tạo được ảnh hưởng tích cực đến đời sống tinh thần và vật chất của xã hội, đặc biệt là Thành phố Hồ Chí Minh và khu vực phía Nam.",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  textAlign: TextAlign.justify,

                ),
              ),
          ],
        ),
      ),
      ),
    );

  }
}