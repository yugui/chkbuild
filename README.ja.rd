= chkbuild

chkbuild �ϡ����Ū�˥��եȥ�������ӥ�ɤ���
�ӥ�ɤε�Ͽ�� HTML �ڡ����Ȥ����������ޤ���

== ���

���� ů <akr@fsij.org>

== ��ħ

* timeout ������Ǥ��ޤ�

  ���ꤷ�����֤��᤮���顢�ץ����� kill ���ޤ���
  ���Τ��ᡢ�ӥ�ɤ���λ���ʤ����꤬���ä����Ǥ⡢���ꤷ�����֤ǽ�λ���ޤ���

* backtrace ��ưŪ�ˤȤ�ޤ�

  �ӥ�ɤη�� core ����������Ƥ����顢��ưŪ�� gdb ��ư����
  backtrace ��Ͽ���ޤ���

* ���ε�Ͽ�ϼ�ưŪ�� gzip ���̤���ޤ�

* ����ε�Ͽ�Ȥ���Ӥ�Ԥ��ޤ�
  ���ΤȤ����ޥ�ɤ�¹Ԥ�������ʤɡ����ۤʤ�Τ������ʤ�Τϻ������ִ����졢
  ��ӷ�̤ˤ�ɽ��ޤ���
  �ġ��Υӥ�ɸ�ͭ��������ִ������оݤ����ꤹ�뤳�Ȥ��ǽ�Ǥ���

* cvs, svn �ǥ���������������硢ViewVC �ˤ�� diff �ؤΥ�󥯤������Ǥ��ޤ���

* �ҤȤĤΥӥ����Ǽ��Ԥ��������Ȥ��ˡ����μ��Ԥ˰�¸���ʤ���ʬ��³�Ԥ��뤳�Ȥ��Ǥ��ޤ���

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

      % export U=foo
      % cd /home/$U
      % cvs -d :pserver:anonymous@cvs.m17n.org:/cvs/ruby co chkbuild

(2) chkbuild ������

    ���ޤ��ޤʥ���ץ�����꤬ sample �ǥ��쥯�ȥ�ˤ���ޤ��Τǡ�
    Ŭ���ʤ�Τ��Խ����ޤ���
    �ޤ���start-build �ϥ���ץ��ƤӽФ�������ץȤǤ���

      % cd chkbuild
      % vi sample/build-ruby
      % vi start-build

    �������ƤˤĤ��ƾܤ����ϼ���ǽҤ٤ޤ���

    �Ȥ�����դ�ɬ�פʤΤϡ�RSS ��Ȥ��������� URL ���̤�������ɬ�פ����뤿�ᡢ
    ��̤�������� URL �� ChkBuild.top_uri = "..." �����ꤹ��ɬ�פ�����ޤ���
    ����ˤĤ��Ƥ� sample/build-ruby �˥����Ȥ�����ޤ���
    (���������Ԥ�ʤ���硢��Ŭ�ڤ� URL �� HTML �������ޤ�ޤ���)

    �ʤ�����������Ƥ��ѹ�������ruby start-build �Ȥ��Ƽ¹Ԥ������ϡ�
    Ruby �� main trunk �Ȥ����Ĥ��Υ֥�����
    /home/foo/chkbuild/tmp �ʲ��ǥӥ�ɤ��ޤ���

    foo �桼���ǥӥ�ɤ�����硢���� chkbuild �桼���ǤΥӥ�ɤμ���ˤʤ�ޤ��Τǡ�
    �ӥ�ɷ�̤������Ƥ����ޤ���

      % rm -rf tmp

(3) chkbuild �桼���κ���

    chkbuild ��ư�����ѤΥ桼�������롼�פ���ޤ���
    �������ƥ��Τ��ᡢɬ�����ѥ桼�������롼�פ��äƤ���������
    �ޤ���chkbuild ���롼�פ� foo ��ä������
    �ޤ����ʲ��Τ褦�ʥ����ʡ����롼�ס��⡼�ɤǥǥ��쥯�ȥ���ꡢ
    chkbuild �桼�����Ȥ� build, public_html �ʲ��ˤ����񤭹���ʤ��褦�ˤ��ޤ���

      /home/chkbuild              user=foo group=chkbuild mode=2755
      /home/chkbuild/build        user=foo group=chkbuild mode=2775
      /home/chkbuild/public_html  user=foo group=chkbuild mode=2775

      % su
      # adduser --disabled-login --no-create-home chkbuild
      ## adduser --disabled-login --no-create-home --shell /home/$U/chkbuild/start-build chkbuild
      # usermod -G ...,chkbuild $U
      # cd /home
      # mkdir chkbuild
      # chown $U:chkbuild chkbuild
      # chmod 2755 chkbuild
      # mkdir chkbuild/build
      # mkdir chkbuild/public_html
      # chown $U:chkbuild chkbuild/build chkbuild/public_html
      # chmod 2775 chkbuild/build chkbuild/public_html
      # exit

(4) �����ǥ��쥯�ȥ������

      % ln -s /home/chkbuild /home/$U/chkbuild/tmp

    �ǥե���Ȥ�����Τޤ� /home/chkbuild �ʲ��ǥӥ�ɤ��������ˤϤ��Τ褦��
    ����ܥ�å���󥯤���Τ���ñ�Ǥ���

(5) rsync �ˤ��ե�����Υ��åץ���

    chkbuild ��ư�����ۥ��Ȥ� chkbuild �����������ե�������������
    HTTP �����Ф��ۤʤ��硢ssh ��ͳ�� rsync �ǥ��ԡ����뤳�Ȥ��Ǥ��ޤ���

    ���Τ���ˤϡ��ޤ��̿��˻��Ѥ��� (�ѥ��ե졼���Τʤ�) ssh ���Ф��������ޤ���

      % ssh-keygen -N '' -t rsa -f chkbuild-upload -C chkbuild-upload

    ���åץ��ɤ����ե�������Ǽ����ǥ��쥯�ȥ�� HTTP �����ФǺ��ޤ�
    �����Ǥ� /home/$U/public_html/chkbuild ��Ȥ����Ȥˤ��ޤ���

      % mkdir -p /home/$U/public_html/chkbuild
 
    HTTP �����Фǥ��åץ��ɤ������뤿��� rsync daemon ���������ޤ���
    �����Ǥ� /home/$U/.ssh/chkbuild-rsyncd.conf �˺��Ȥ��ޤ���
    ���������Ȥä� rsync daemon �� /home/$U/public_html/chkbuild ���ؤ�
    �񤭹������Ѥˤʤ�ޤ���

      /home/$U/.ssh/chkbuild-rsyncd.conf :
      [upload]
      path = /home/$U/public_html/chkbuild
      use chroot = no
      read only = no
      write only = yes
    
    HTTP �����Фǥ��åץ��ɤ�������桼���� ~/.ssh/authorized_keys ��
    �ʲ���ä��ޤ���
    ����Ϥ����ǻȤ����Ф��嵭������Ǥ� rsync daemon �ε�ư���Ѥˤ����ΤǤ���

      command="/usr/bin/rsync --server --daemon --config=/home/$U/.ssh/chkbuild-rsyncd.conf .",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty �嵭���������������� chkbuild-upload.pub ������

    chkbuild ��ư�����ۥ��Ȥǡ�HTTP �����Ф� ssh fingerprint ��Ͽ���ޤ���
    HTTP �����ФΥۥ���̾�� http-server �Ȥ��ޤ���

      % mkdir /home/chkbuild/.ssh                                         
      % ssh-keyscan -t rsa http-server > /home/chkbuild/.ssh/known_hosts

    ��������������Ф���̩���� chkbuild ��ư�����ۥ��Ȥ�
    /home/chkbuild/.ssh/ �˥��ԡ����ޤ�
    ��������̩���� chkbild �桼�����ɤ��褦�ʥ��롼�ץѡ��ߥå�����
    ���ꤷ�ޤ���

      % cp chkbuild-upload chkbuild-upload.pub /home/chkbuild/.ssh/
      % su
      # chgrp chkbuild /home/chkbuild/.ssh/chkbuild-upload
      # chmod g+r /home/chkbuild/.ssh/chkbuild-upload

    �����ơ�start-build ��ǰʲ��ιԤ�ͭ���ˤ��ޤ���

      ChkBuild.rsync_ssh_upload_target("remoteuser@http-server::upload/dir", "/home/chkbuild/.ssh/chkbuild-upload")

    ����ˤ�� HTTP �����Ф� /home/$U/public_html/chkbuild/dir �˥��ԡ������
    �褦�ˤʤ�ޤ���

(6) HTTP �����Ф�����

    chkbuild �ϥǥ��������Ӱ�����󤹤뤿�ᡢ�ե������ gzip ���̤��ޤ���
    ���̤����ե������ *.html.gz �� *.txt.gz �Ȥ����ե�����̾�ˤʤ�ޤ���
    �����Υե������֥饦������������뤿��ˤϰʲ��Τ褦�ʥإå���
    HTTP �����Ф���֥饦���������ʤ���Фʤ�ޤ���

      Content-Type: text/html
      Content-Encoding: gzip

    �ޤ���rss �Ȥ����ե�����Ǥ� RSS ���󶡤���Τǡ��ʲ��Υإå���Ĥ��ޤ���

      Content-Type: application/rss+xml

    ������Ԥ�������ˡ�� HTTP �����Ф˰�¸���ޤ�����
    Apache �ξ��� mod_mime �⥸�塼��ǥإå�������Ǥ��ޤ���
    http://httpd.apache.org/docs/2.2/mod/mod_mime.html

    ��������ξ����ˤ�äƶ���Ū�ʤ�꤫���ϰۤʤ�ޤ������㤨�аʲ��Τ褦��
    ����� .htaccess ������뤳�ȤǾ嵭��¸��Ǥ��뤫�⤷��ޤ���

    # ���������Τ�����ˤ��� .gz ���Ф��� AddType ����������
    # .gz �ʥե������ Content-Encoding: gzip �Ȥ���
    # .html ���Ф��� Content-Type: text/html �Ȥ���Τϥ��������Τ������
    # ��äƤ����ΤȤ��Ƥ����ǤϹԤ�ʤ�
    RemoveType .gz
    AddEncoding gzip .gz

    # rss �Ȥ����ե������ Content-Type: application/rss+xml �Ȥ���
    <Files rss>
    ForceType application/rss+xml
    </Files>

(7) ����¹Ԥ�����

      # vi /etc/crontab

    ���Ȥ��С��������� 3��33ʬ�˼¹Ԥ���ˤ� root �� crontab �ǰʲ��Τ褦��
    �����Ԥ��ޤ���

      33 3 * * * cd /home/$U/chkbuild; su chkbuild -c /home/$U/chkbuild/start-build

    su chkbuild �ˤ�ꡢchkbuild �桼���� start-build ��ư���ޤ���

(8) ���ʥ���

    Ruby ��ȯ�Ԥ˸����ߤ����ʤ顢Ruby hotlinks ����Ͽ����Ȥ��������Τ�ޤ���

    http://www.rubyist.net/~kazu/samidare/latest

== ����

chkbuild ������ϡ�Ruby �ǵ��Ҥ���ޤ���
�ºݤΤȤ���chkbuild �����Τ� chkbuild.rb �Ȥ��� Ruby �Υ饤�֥��Ǥ��ꡢ
chkbuild.rb �����Ѥ��륹����ץȤ򵭽Ҥ��뤳�Ȥ�����Ȥʤ�ޤ���

== �������ƥ�

chkbuild �ˤ�ꡢcvs/svn/git �����Фʤɤ�������Ǥ���ǿ��Ǥ򥳥�ѥ��뤹�뤳�Ȥϡ�
�����Ф˽񤭹���볫ȯ�Ԥ� �����Ф����äƤ��륳���ɤ��Ѥ��뤳�Ȥˤʤ�ޤ���

��ȯ�Ԥ��Ѥ��뤳�Ȥ��̾����ꤢ��ޤ���
�⤷��ȯ�Ԥ��Ѥ��ʤ��Τʤ�С����⤽�⤢�ʤ��Ϥ��Υץ�����Ȥ�ʤ��Ǥ��礦��

�������������Ф����äƤ��륳���ɤ��Ѥ���Τ���̯�������Ϥ��Ǥ��ޤ���
�����Ф�����å����졢���դΤ����ʪ�����ʥ����ɤ����������ǽ��������ޤ���
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

* index.html ����������

== LICENSE

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
OF SUCH DAMAGE.

(The modified BSD license)
