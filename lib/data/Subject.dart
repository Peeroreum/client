class Subject {
  static const subject = ["국어", "영어", "수학", "사회", "과학", "기타"];
  static const middleSubject = <String, List<String>> {
    "국어": ["공통"],
    "영어": ["공통"],
    "수학": ["공통"],
    "사회": ["공통", "역사", "도덕"],
    "과학": ["공통"],
    "기타": ["기술·가정", "정보", "기타"]
  };

  static const highSubject = <String, List<String>> {
    "국어": ["공통", "화법과 작문", "독서", "언어와 매체", "문학"],
    "영어": ["공통"],
    "수학": ["공통", "수학 I", "수학 II", "미적분", "확률과 통계"],
    "사회": ["공통", "한국사", "한국지리", "세계지리", "세계사", "동아시아사", "경제", "정치와 법", "사회·문화", "생활과 윤리", "윤리와 사상"],
    "과학": ["공통", "물리 I", "물리 II", "화학 I", "화학 II", "생명과학 I", "생명과학 II", "지구과학 I", "지구과학 II"],
    "기타": ["기술·가정", "정보", "제2외국어", "한문", "기타"]
  };
}