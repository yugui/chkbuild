= chkbuild

chkbuild �ϡ����Ū�˥��եȥ�������ӥ�ɤ���
�ӥ�ɤε�Ͽ�� HTML �ڡ����Ȥ����������ޤ���

== ���

���� ů <akr@m17n.org>

== ��ħ

* timeout ������Ǥ��ޤ�

  ���ꤷ�����֤��᤮���顢�ץ����� kill ���ޤ���
  ���Τ��ᡢ�ӥ�ɤ���λ���ʤ����꤬���ä����Ǥ⡢���ꤷ�����֤ǽ�λ���ޤ���

* backtrace ��ưŪ�ˤȤ�ޤ�

  �ӥ�ɤη�� core ����������Ƥ����顢��ưŪ�� gdb ��ư����
  backtrace ��Ͽ���ޤ���

* ���ε�Ͽ�ϼ�ưŪ�� gzip ���̤���ޤ�

* ����ε�Ͽ�Ȥ� diff ���������ޤ�

== û���ʥ桼���Τ�������֤���ӻ�� ruby �κǿ��Ǥ�ӥ�ɤ��Ƥߤ���ˡ

  % cd $HOME
  % cvs -d :pserver:anonymous@cvs.m17n.org:/cvs/ruby co chkbuild
  % cd chkbuild
  % ruby start-build

  % w3m tmp/public_html/ruby-trunk/summary.html 
  % w3m tmp/public_html/ruby-trunk-pth/summary.html 
  % w3m tmp/public_html/ruby-1.8/summary.html 
  % w3m tmp/public_html/ruby-1.8-pth/summary.html 

  % rm -rf tmp

  ������ˡ�Ϥ����ޤǤ���ư������ΤǤ��äơ�
  ����� cron �����Ū�˼¹Ԥ��뤳�ȤϤ��ʤ��Ǥ���������

== ����

�ʲ�����Ǥϡ����ʤ��Υ桼��̾�� foo �ǡ�
/home/foo/chkbuild �� chkbuild �����֤��뤳�Ȥ��ꤷ�ޤ���
¾�Υǥ��쥯�ȥ�����֤������Ŭ�����ѹ����Ƥ���������

(1) chkbuild �Υ�������ɡ�Ÿ��

      % cd /home/foo
      % cvs -d :pserver:anonymous@cvs.m17n.org:/cvs/ruby co chkbuild

(2) chkbuild ������

    ���ޤ��ޤʥ���ץ�����꤬ sample �ǥ��쥯�ȥ�ˤ���ޤ��Τǡ�
    Ŭ���ʤ�Τ��Խ����ޤ���
    �ޤ���start-build �ϥ���ץ��ƤӽФ�������ץȤǤ���

      % cd chkbuild
      % vi sample/build-ruby
      % vi start-build

    �������ƤˤĤ��ƾܤ����ϼ���ǽҤ٤ޤ���

    �ʤ�����������Ƥ��ѹ�������ruby start-build �Ȥ��Ƽ¹Ԥ������ϡ�
    Ruby �� main trunk �� ruby_1_8 branch ��
    ���줾�� --enable-pthread ̵����ͭ�������Ȥ���
    ��4����� /home/foo/chkbuild/tmp �ʲ��ǥӥ�ɤ��ޤ���

    foo �桼���ǥӥ�ɤ�����硢���� chkbuild �桼���ǤΥӥ�ɤμ���ˤʤ�ޤ��Τǡ�
    �ӥ�ɷ�̤������Ƥ����ޤ���

      % rm -rf tmp

(3) chkbuild �桼���κ���

    chkbuild ��ư�����ѤΥ桼�������롼�פ���ޤ���
    �������ƥ������ͳ�⤢�ꡢɬ�����ѥ桼�������롼�פ��äƤ���������
    �ޤ���chkbuild ���롼�פ� foo ��ä������
    �ޤ����ʲ��Τ褦�ʥ����ʡ����롼�ס��⡼�ɤǥǥ��쥯�ȥ���ꡢ
    chkbuild �桼�����Ȥ� build, public_html �ʲ��ˤ����񤭹���ʤ��褦�ˤ��ޤ���

      /home/chkbuild              user=foo group=chkbuild mode=2750
      /home/chkbuild/build        user=foo group=chkbuild mode=2775
      /home/chkbuild/public_html  user=foo group=chkbuild mode=2775

      % su
      # adduser --disabled-login --no-create-home --shell /home/foo/chkbuild/start-build chkbuild
      # usermod -G ...,chkbuild foo
      # cd /home
      # mkdir chkbuild
      # chown foo:chkbuild chkbuild
      # chmod 2750 chkbuild
      # su foo
      % cd chkbuild
      % mkdir build public_html
      % chgrp chkbuild build public_html
      % chmod 2775 build public_html
      % exit
      # exit

(4) �����ǥ��쥯�ȥ������

      % ln -s /home/chkbuild tmp

    �ǥե���Ȥ�����Τޤ� /home/chkbuild �ʲ��ǥӥ�ɤ��������ˤϤ��Τ褦��
    ����ܥ�å���󥯤���Τ���ñ�Ǥ���

(6) ����¹Ԥ�����

      # vi /etc/crontab

    ���Ȥ��С��������� 3��33ʬ�˼¹Ԥ���ˤ� /etc/crontab �˰ʲ��ιԤ��������ޤ���

      33 3 * * * root cd /home/foo/chkbuild; su chkbuild

    su chkbuild �ˤ�ꡢchkbuild �桼�������ꤷ��������Ȥ������ꤷ��
    /home/foo/chkbuild/start-build ����ư���ޤ���

(7) ���������ʥ���

    Ruby ��ȯ�Ԥ˸����ߤ����ʤ顢Ruby hotlinks ����Ͽ����Ȥ��������Τ�ޤ���

    http://www.rubyist.net/~kazu/samidare/latest

== ����

chkbuild ������ϡ�Ruby �ǵ��Ҥ���ޤ���
�ºݤΤȤ���chkbuild �����Τ� chkbuild.rb �Ȥ��� Ruby �Υ饤�֥��Ǥ��ꡢ
chkbuild.rb �����Ѥ��륹����ץȤ򵭽Ҥ��뤳�Ȥ�����Ȥʤ�ޤ���

== �������ƥ�

chkbuild �ˤ�ꡢCVS �����Ф�������Ǥ���ǿ��Ǥ򥳥�ѥ��뤹�뤳�Ȥϡ�
CVS �����Ф˽񤭹���볫ȯ�Ԥ� CVS �����Ф����äƤ��륳���ɤ��Ѥ��뤳�Ȥˤʤ�ޤ���

��ȯ�Ԥ��Ѥ��뤳�Ȥ��̾����ꤢ��ޤ���
�⤷��ȯ�Ԥ��Ѥ��ʤ��Τʤ�С����⤽�⤢�ʤ��Ϥ��Υץ�����Ȥ�ʤ��Ǥ��礦��

��������CVS �����Ф����äƤ��륳���ɤ��Ѥ���Τ���̯�������Ϥ��Ǥ��ޤ���
CVS �����Ф�����å����졢���դΤ����ʪ�����ʥ����ɤ����������ǽ��������ޤ���
���Ȥ��С����ʤ��θ��¤Ǽ¹Ԥ��Ƥ����顢���ʤ��Υۡ���ǥ��쥯�ȥ꤬�������Ƥ��ޤ������Τ�ޤ��󤷡�
���ʤ�����̩������ޤ�Ƥ��ޤ������Τ�ޤ���

���Τ��ᡢchkbuild �Ͼ��ʤ��Ȥ����ѥ桼���Ǽ¹Ԥ���
���ʤ��Υۡ���ǥ��쥯�ȥ���ѹ���ä����ʤ��褦�ˤ��٤��Ǥ���

�ޤ� chkbuild �Υ�����ץȼ��Ȥ�񤭴������ʤ��褦�ˡ�chkbuild �Ϥ������ѥ桼���Ȥ��̤Υ桼���ν�ͭ�Ȥ��٤��Ǥ���
�ʤ��������Ǥ������̤Υ桼���פΤ�������ѤΥ桼�����Ѱդ���ɬ�פϤ���ޤ���
���ʤ��θ��¤Ǥ⤤���Ǥ�����root �Ǥ⤫�ޤ��ޤ���

�ʤ����������տ������ꤿ�����ˤϡ�
xen, chroot, jail, user mode linux, VMware, ... �ʤɤǴĶ�����ꤹ�뤳�Ȥ⸡Ƥ���Ƥ���������

== TODO

* index.html ���������롣

