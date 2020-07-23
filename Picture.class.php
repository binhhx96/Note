<?
require_once 'AWSSDKforPHP/aws.phar';
use Aws\S3\S3Client;
use Aws\Common\Enum\Region;
use Aws\S3\Exception\S3Exception;
use Guzzle\Http\EntityBody;

class Picture {

	private $msg;

	const MAX_FILESIZE = 20971520;

	public function __construct(){
	}

	public function error(){
		return $this->msg;
	}


	/*
	* アップロード可能なMIMEタイプ
	*
	*/
	public static function isMimeType($mime=null){
		static $st_map	= null;
		if(!$st_map){
			$st_map	= array(
			    	'image/jpeg' => 'jpg',
				    'image/png'  => 'png',
				    'image/gif'  => 'gif',
				);
		}
		if (isset($st_map[$mime])) return $st_map[$mime];
		return $st_map;
	}


	/*
	* アップロード時に使うファイル名生成
	*
	*/
	public static function makeFileName($picid){

		srand((double)microtime()*1000000);	// 乱数の初期化
		$r_number1 = rand(0, 999999);

		srand((double)microtime()*1000000);		//乱数の初期化
		$r_number2 = rand(0, 999999);

		return sprintf("%06d%08d%06d", $r_number1, $picid, $r_number2);
	}



	/*
	* ファイルアップロード
	*
	*/
    public function fileUpload($inFile, $toFileName, array $extensions = [], $s3key = null, $inputName = 'picture')
    {
        if (!$inFile[$inputName]['tmp_name']) {
            $this->msg = "ファイルを添付して下さい";
            return false;
        }

        if ($_SERVER['CONTENT_LENGTH'] > self::MAX_FILESIZE) {
            $this->msg = "添付ファイルが大きすぎます。ファイルサイズを縮小して下さい";
            return false;
        }

        //{{ MIMEタイプを取得
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mimeType = finfo_file($finfo, $inFile[$inputName]['tmp_name']);
        finfo_close($finfo);

        $in_ImageMimeTypeList = self::isMimeType();

        if (!$in_ImageMimeTypeList[$mimeType]) {
            $this->msg = "指定の添付ファイルはアップロードできません{$mimeType}";
            return false;
        }

        $extension = $in_ImageMimeTypeList[$mimeType];


        if (!is_uploaded_file($inFile[$inputName]['tmp_name'])) {
            $this->msg = "添付するファイルが選択されていません";
            return false;
        }

        //{{ テンポラリーファイル
        $picName = rand(0, 9999) . time() . rand(0, 9999) . ".{$extension}";
        $picFile = sys_get_temp_dir() . "/" . $picName;


        if (!move_uploaded_file($inFile[$inputName]['tmp_name'], $picFile)) {
            $this->msg = "ファイルがアップロードできませんでした";
            return false;
        }

        $this->uploadToS3($picFile, $toFileName, $extensions, $s3key);

        return true;
    }

    private function uploadToS3($picFile, $toFileName, array $extensions = [], $s3key = null) {
        $s3client = S3Client::factory(array(
            'key'    => AWS_ACCESS_KEY,
            'secret' => AWS_SECRET_KEY,
            'region' => Region::AP_NORTHEAST_1,
        ));

        //{{ $extsで指定された拡張子に変換
        $fileInfo = new \finfo(FILEINFO_MIME_TYPE);

        $s3BucketKey = $s3key ? $s3key : AWS_S3_BUCKET_SUPPORT_KEY;
        foreach ($extensions as $val) {
            $pic = $toFileName . ".{$val}";
            Picture::convertFile($picFile, $pic);

            if (!file_exists($pic)) {
                $this->msg = "ファイルがアップロードできませんでした";
                @unlink($picFile);
                return false;
            }

            $result = $s3client->putObject(array(
                'Bucket'       => AWS_S3_BUCKET,
                'Key'          => $s3BucketKey . basename($pic),
                'Body'         => EntityBody::factory(fopen($pic, 'r')),
                'ACL'          => 'public-read',
                'StorageClass' => 'STANDARD',
                'ContentType'  => $fileInfo->file($pic),
                'CacheControl' => "public,max-age=1209600",
                'Expires'      => gmdate('D, d M Y H:i:s T', time() + 1209600),
            ));

        }
        @unlink($picFile);
    }


    /*
    * リサイズやコメントの書き込み・削除など
    *
    */
	static function convertFile($inFile, $outFile, $options=null ){

		$convertPath	= _BIN_CONVERT_PATH;
		$inFile_safe= escapeshellarg($inFile);
		$outFile_safe= escapeshellarg($outFile);
		$optstr	= "";

		//{{ EXIF情報削除以下２行
		$command	= "$convertPath -strip $inFile_safe $inFile_safe";
		exec($command);
		//error_log($command);

		if (is_array($options)){
			foreach ($options as $aKey => $aVal){
				if ($aVal === null) {
					$optstr .= " -$aKey";
				} else {
					$optstr .= " -$aKey ".escapeshellarg($aVal);
				}
			}
		} else {
			if ($options !== null) {
				$optstr .= escapeshellarg($options);
			}
		}
		$command	= "$convertPath $optstr $inFile_safe $outFile_safe";

		$descriptorspec = array(
				0=>array("pipe", "r"), //stdin
				1=>array("pipe", "w"), //stdout
				2=>array("pipe", "w"), //stderr
				);
		$pipes	= null; // Used as Reference
		$proc	= proc_open($command, $descriptorspec, $pipes);

		if (!$proc){
			trigger_error("Cannot open proc '$command'", E_USER_WARNING);

			return false;
		}
		fclose($pipes[0]); // close stdin of proc
		$ctnt	= stream_get_contents($pipes[1]); // read stdout of proc
		$err	= stream_get_contents($pipes[2]); // read stderr of proc
		fclose($pipes[1]); // close stdout of proc
		fclose($pipes[2]); // close stderr of proc
		$retval	= proc_close($proc);
		if ($err) {
			trigger_error("Error '$err'", E_USER_WARNING);
		}
		return ($retval == 0) ? true : false;

	}

}

