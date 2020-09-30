<?php
namespace App\Middleware;
use Zend\Diactoros\Response\RedirectResponse;

class AdminAuthenticationMiddleware
{
    public function getSessionName() {
        return 'Auth.Admin';
    }

    public function redirectTo() {
        return '/admin/login';
    }

    public function __invoke($request, $response, $next)
    {
        $authSessionName = $this->getSessionName();

        if(!$request->session()->read($authSessionName)) {
            if($request->is('ajax')) {
                $responseBody = [
                    'code'      => 403,
                    'status'    =>  'error',
                    'message'   =>  __('ログイン有効期限が切れたため、再度ログインしてください。'),
                    'msg'       =>  __('ログイン有効期限が切れたため、再度ログインしてください。'),
                ];

                return $response->withType('application/json')->withStringBody(json_encode($responseBody));
            } else {
                return new RedirectResponse($this->redirectTo());
            }
        };

        return $next($request, $response);
    }
}
